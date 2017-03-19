defmodule Vutuv.SessionController do
  use Vutuv.Web, :controller

  def new(conn, _) do
    render conn, "new.html", body_class: "stretch"
  end

  def create(conn, %{"session" => %{"email" => email}}) do
    case Vutuv.Auth.login_by_email(conn, email) do
      {:ok, conn} ->
        case conn.cookies["_vutuv_fbs_temp"] do
          nil ->
            conn
            |> render("user_login.html", body_class: "stretch")
          _ ->
            conn
            |> render("pin_user_login.html", body_class: "stretch")
        end
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, gettext("Invalid email"))
        |> render("new.html", body_class: "stretch")
    end
  end

  def create(conn, %{"session" => %{"pin" => pin}}) do
    conn
    |> unform_pin_cookie
    |> Vutuv.MagicLinkHelpers.check_pin(pin, "login")
    |> case do
      {:ok, user} -> #correct, delete cookie, login user
        Vutuv.Auth.login(conn, user)
        |> delete_resp_cookie("_vutuv_fbs_temp", max_age: 1800)
        |> put_flash(:info, gettext("Welcome back!"))
        |> redirect(to: user_path(conn, :show, user))
      {:error, reason} -> #incorrect, inform user
        conn
        |> put_flash(:error, reason)
        |> redirect(to: page_path(conn, :index))
      {:expired, message} -> #locked out, delete cookie
        conn
        |> delete_resp_cookie("_vutuv_fbs_temp", max_age: 1800)
        |> put_flash(:error, message)
        |> redirect(to: session_path(conn, :new))
      :lockout -> #locked out, delete cookie
        conn
        |> delete_resp_cookie("_vutuv_fbs_temp", max_age: 1800)
        |> put_flash(:error, gettext("Too many incorrect attempts."))
        |> redirect(to: session_path(conn, :new))
    end
  end

  def show(conn, %{"magiclink"=>link}) do
    case Vutuv.MagicLinkHelpers.check_magic_link(link, "login") do
      {:ok, user} ->
        Vutuv.Auth.login(conn,user)
        |> put_flash(:info, gettext("Welcome back!"))
        |> redirect(to: user_path(conn, :show, user))
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: page_path(conn, :index))
    end
  end

  def delete(conn, _) do
    user = conn.assigns[:current_user]
    conn
    |> Vutuv.Auth.logout()
    |> redirect(to: user_path(conn, :show, user))
  end

  defp unform_pin_cookie(%{cookies: %{"_vutuv_fbs_temp" => payload}} = conn) do
    salt = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:secret_key_base]
    {:ok, email} = Phoenix.Token.verify(conn, salt, payload)
    email
  end
end

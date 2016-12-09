defmodule Vutuv.SessionController do
  use Vutuv.Web, :controller

  @api_url ~s(https://graph.facebook.com/v2.3/)

  def new(conn, _) do
    render conn, "new.html", body_class: "stretch"
  end

  def create(conn, %{"session" => %{"email" => email}}) do
    case Vutuv.Auth.login_by_email(conn, email) do
      {:ok, conn} ->
        conn
        |> render("user_login.html", body_class: "stretch")
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, gettext("Invalid email"))
        |> render("new.html", body_class: "stretch")
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
end

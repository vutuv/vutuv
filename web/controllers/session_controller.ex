defmodule Vutuv.SessionController do
  use Vutuv.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email}}) do
    case Vutuv.Auth.login_by_email(conn, email, repo: Repo) do
      {:ok, link, conn} ->
        conn
        |> put_flash(:info, gettext("localhost:4000/magic/")<>link)
        |> redirect(to: page_path(conn, :index))
        #|> redirect(to: user_path(conn, :show, conn.assigns[:current_user]))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, gettext("Invalid email"))
        |> render("new.html")
    end
  end

  def show(conn, %{"magiclink"=>link}) do
    case Vutuv.MagicLink.login_magic_link(link) do
      {:ok, user} -> 
        conn=Vutuv.Auth.login(conn,user)
        conn
        |> put_flash(:info, gettext("Welcome back"))
        |> redirect(to: user_path(conn, :show, conn.assigns[:current_user]))
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: page_path(conn, :index))
    end
    
  end

  def delete(conn, _) do
    conn
    |> Vutuv.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end
end

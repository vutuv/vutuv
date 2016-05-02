defmodule Vutuv.SessionController do
  use Vutuv.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email}}) do
    case Vutuv.Auth.login_by_email(conn, email, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome!")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Vutuv.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end
end

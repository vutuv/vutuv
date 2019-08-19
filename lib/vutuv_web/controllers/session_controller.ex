defmodule VutuvWeb.SessionController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.Sessions
  alias VutuvWeb.Auth.Login

  plug :guest_check when action in [:new, :create]

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => params}) do
    case Login.verify(params) do
      {:ok, user} ->
        conn
        |> add_session(user, params)
        |> put_flash(:info, gettext("User successfully logged in."))
        |> redirect(to: get_session(conn, :request_path) || Routes.user_path(conn, :show, user))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, %{"id" => session_id}) do
    case session_id |> Sessions.get_session() |> Sessions.delete_session() do
      {:ok, %{user_id: ^user_id}} ->
        conn
        |> delete_session(:phauxth_session_id)
        |> put_flash(:info, gettext("User successfully logged out."))
        |> redirect(to: Routes.user_path(conn, :new))

      _ ->
        conn
        |> put_flash(:error, gettext("Unauthorized"))
        |> redirect(to: Routes.user_path(conn, :show, user_id))
    end
  end

  defp add_session(conn, user, _params) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> delete_session(:request_path)
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
  end
end

defmodule VutuvWeb.Api.SessionController do
  use VutuvWeb, :controller

  import VutuvWeb.Api.AuthorizeConn

  alias Vutuv.Sessions
  alias VutuvWeb.Auth.{Login, Token}

  plug :guest_check when action in [:create]

  def create(conn, %{"session" => params}) do
    case Login.verify(params) do
      {:ok, user} ->
        {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})
        token = Token.sign(%{"session_id" => session_id})
        render(conn, "info.json", %{info: token})

      {:error, _message} ->
        error(conn, :unauthorized, 401)
    end
  end
end

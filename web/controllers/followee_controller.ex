defmodule Vutuv.FolloweeController do
  use Vutuv.Web, :controller
  plug :assign_user

  alias Vutuv.Connection

  def index(conn, _params) do
    render(conn, "index.html", user: conn.assigns[:user])
  end

  defp assign_user(conn, _opts) do
    case conn.params do
      %{"user_id" => user_id} ->
        case Repo.get(Vutuv.User, user_id)
             |> Repo.preload([:followees]) do
          nil  -> invalid_user(conn)
          user -> assign(conn, :user, user)
        end
      _ -> invalid_user(conn)
    end
  end

  defp invalid_user(conn) do
    conn
    |> put_flash(:error, "Invalid user!")
    |> redirect(to: page_path(conn, :index))
    |> halt
  end
end

defmodule Vutuv.FolloweeController do
  use Vutuv.Web, :controller
  plug :resolve_slug

  def index(conn, _params) do
    render(conn, "index.html", user: conn.assigns[:user])
  end

  def resolve_slug(conn, _opts) do
    case conn.params do
      %{"user_slug" => slug} ->
        case Repo.one(from s in Vutuv.Slug, where: s.value == ^slug, select: s.user_id) do
          nil  -> invalid_slug(conn)
          user_id ->
            user = Repo.one(from u in Vutuv.User, where: u.id == ^user_id)
            assign(conn, :user, user)
        end
      _ -> invalid_slug(conn)
    end
  end

  defp invalid_slug(conn) do
    conn
    |> put_flash(:error, "404")
    |> redirect(to: page_path(conn, :index))
    |> halt
  end
end

defmodule Vutuv.UserResolveSlug do
  import Plug.Conn
  import Ecto.Query
  alias Vutuv.Repo

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case conn.params do
      %{"user_slug" => slug} ->
        case Repo.one(from s in Vutuv.Slug, where: s.value == ^slug, select: s.user_id) do
          nil  -> Vutuv.UserController.invalid_slug(conn)
          user_id ->
            user = Repo.one(from u in Vutuv.User, where: u.id == ^user_id)
            assign(conn, :user, user)
        end
      _ -> Vutuv.UserController.invalid_slug(conn)
    end
  end
end

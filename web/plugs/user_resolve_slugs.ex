defmodule Vutuv.Plug.UserResolveSlug do
  import Plug.Conn
  import Ecto.Query
  import Phoenix.Controller
  alias Vutuv.Repo
  alias Vutuv.Router.Helpers

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case conn.params do
      %{"user_slug" => slug} ->
        case Repo.one(from s in Vutuv.Slug, where: s.value == ^slug) do
          nil  -> Vutuv.UserController.invalid_slug(conn)
          %{disabled: false, user_id: user_id} ->
            user = Repo.get!(Vutuv.User, user_id)
            if(user.active_slug != slug) do
              #redirect(conn, to: "#{String.replace(conn.request_path, slug, user.active_slug)}?#{Plug.Conn.Query.encode(conn.query_params)}")
              redirect(conn, to: Helpers.user_path(conn, :show, user))
            else
              assign(conn, :user, user)
            end
          _ -> Vutuv.UserController.invalid_slug(conn)
        end
      _ -> Vutuv.UserController.invalid_slug(conn)
    end
  end
end

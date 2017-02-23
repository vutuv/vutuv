defmodule Vutuv.Plug.UserResolveSlug do
  import Plug.Conn
  import Ecto.Query
  import Phoenix.Controller
  alias Vutuv.Repo
  alias Vutuv.Router.Helpers

  def init(opts) do
    opts
  end

  def call(%{params: %{"user_slug" => slug}} = conn, _opts) do
    Repo.one(from s in Vutuv.Slug, join: u in assoc(s, :user), where: s.value == ^slug and not is_nil(u.id), preload: [:user])
    |> eval_slug(conn)
  end

  def call(%{params: %{"slug" => slug}} = conn, _opts) do
    Repo.one(from s in Vutuv.Slug, join: u in assoc(s, :user), where: s.value == ^slug and not is_nil(u.id), preload: [:user])
    |> eval_slug(conn)
  end

  def call(conn, _params) do
    invalid_slug(conn)
  end

  defp eval_slug(%{disabled: false, user: user, value: slug}, conn) do
    if(user.active_slug != slug) do
      redirect(conn, to: Helpers.user_path(conn, :show, user))
    else
      conn
      |> assign(:user_id, user.id)
      |> assign(:user, user)
    end
  end

  defp eval_slug(_, conn) do
    invalid_slug(conn)
  end

  defp invalid_slug(conn) do
    conn
    |> put_status(:not_found)
    |> render(Vutuv.ErrorView, "404.html")
    |> halt
  end
end

defmodule Vutuv.TagController do
  use Vutuv.Web, :controller

  alias Vutuv.Tag
  alias Vutuv.Locale
  alias Vutuv.TagLocalization

  plug :resolve_tag

  def index(conn, _params) do
    tags_count = Repo.one(from t in Tag, select: count(t.id))
    tags = 
      from(t in Tag)
      |> Vutuv.Pages.paginate(conn.params, tags_count)
      |> Repo.all
    render(conn, "index.html", tags: tags, tags_count: tags_count)
  end

  def show(conn, _params) do
    tag = conn.assigns[:tag]
    render(conn, "show.html", tag: tag, loc: Vutuv.Tag.resolve_localization(tag, conn.assigns[:locale]))
  end

  defp resolve_tag(%{params: %{"slug" => slug}} = conn, _opts) do
    Repo.one(from t in Vutuv.Tag, where: t.slug == ^slug)
    |> case do
      nil -> 
        conn
        |> put_status(:not_found)
        |> render(Vutuv.ErrorView, "404.html")
        |> halt
      tag ->
        assign(conn, :tag, tag)
    end
  end

  defp resolve_tag(conn, _opts), do: conn
end

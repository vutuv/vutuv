defmodule Vutuv.TagController do
  use Vutuv.Web, :controller

  alias Vutuv.Tag
  alias Vutuv.Locale
  alias Vutuv.TagLocalization

  plug :resolve_tag

  def index(conn, _params) do
    tags = Repo.all(Tag)
    render(conn, "index.html", tags: tags)
  end

  def show(conn, _params) do
    tag = 
      conn.assigns[:tag]
      |> Repo.preload([
        tag_localizations: from(t in Vutuv.TagLocalization, 
          where: t.locale_id == ^(Locale.locale_id(conn.assigns[:locale])),
          preload: [:tag_urls])])
    render(conn, "show.html", tag: tag, loc: hd(tag.tag_localizations))
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

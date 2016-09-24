defmodule Vutuv.Api.UrlView do
  use Vutuv.Web, :view
  import Vutuv.Api.ApiHelpers

  @attributes ~w(value description)a

  def render("index.json", %{urls: urls}) do
    %{data: render_many(urls, Vutuv.Api.UrlView, "url.json")}
  end

  def render("index_lite.json", %{urls: urls}) do
    %{data: render_many(urls, Vutuv.Api.UrlView, "url_lite.json")}
  end

  def render("show.json", %{url: url}) do
    %{data: render_one(url, Vutuv.Api.UrlView, "url.json")}
  end

  def render("show_lite.json", %{url: url}) do
    %{data: render_one(url, Vutuv.Api.UrlView, "url_lite.json")}
  end

  def render("url.json", %{url: url} = params) do
    render("url_lite.json", params)
    |> Map.put(:attributes, to_attributes(url, @attributes))
  end

  def render("url_lite.json", %{url: url}) do
    %{id: url.id, type: "url"}
  end
end

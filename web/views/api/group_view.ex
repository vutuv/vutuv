defmodule Vutuv.Api.GroupView do
  use Vutuv.Web, :view
  import Vutuv.Api.ApiHelpers

  @attributes ~w(
    name
  )a

  def render("index.json", %{groups: groups}) do
    %{data: render_many(groups, Vutuv.Api.GroupView, "group.json")}
  end

  def render("index_lite.json", %{groups: groups}) do
    %{data: render_many(groups, Vutuv.Api.GroupView, "group_lite.json")}
  end

  def render("show.json", %{group: group}) do
    %{data: render_one(group, Vutuv.Api.GroupView, "group.json")}
  end

  def render("show_lite.json", %{group: group}) do
    %{data: render_one(group, Vutuv.Api.GroupView, "group_lite.json")}
  end

  def render("group.json", %{group: group} = params) do
    render("group_lite.json", params)
    |> put_attributes(group, @attributes)
  end

  def render("group_lite.json", %{group: group}) do
    %{id: group.id, type: "group"}
  end
end

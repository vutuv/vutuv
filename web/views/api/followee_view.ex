defmodule Vutuv.Api.FolloweeView do
  use Vutuv.Web, :view
  import Vutuv.Api.ApiHelpers

  @attributes ~w(
    first_name last_name middlename nickname honorific_prefix honorific_suffix gender
    birthdate
  )a

  def render("index.json", %{followees: followees}) do
    %{data: render_many(followees, Vutuv.Api.FolloweeView, "followee.json")}
  end

  def render("index_lite.json", %{followees: followees}) do
    %{data: render_many(followees, Vutuv.Api.FolloweeView, "followee_lite.json")}
  end
  
  def render("followee.json", %{followee: followee} = params) do
    render("followee_lite.json", params)
    |> put_attributes(followee, @attributes)
  end

  def render("followee_lite.json", %{followee: followee}) do
    %{id: followee.id, type: "user"}
  end
end

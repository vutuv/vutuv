defmodule Vutuv.Api.FollowerView do
  use Vutuv.Web, :view
  import Vutuv.Api.ApiHelpers

  @attributes ~w(
    first_name last_name middlename nickname honorific_prefix honorific_suffix gender
    birthdate
  )a

  def render("index.json", %{followers: followers}) do
    %{data: render_many(followers, Vutuv.Api.FollowerView, "follower.json")}
  end

  def render("index_lite.json", %{followers: followers}) do
    %{data: render_many(followers, Vutuv.Api.FollowerView, "follower_lite.json")}
  end

  def render("follower.json", %{follower: follower} = params) do
    render("follower_lite.json", params)
    |> put_attributes(follower, @attributes)
  end

  def render("follower_lite.json", %{follower: follower}) do
    %{id: follower.id, type: "user"}
  end
end

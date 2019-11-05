defmodule VutuvWeb.Api.FolloweeView do
  use VutuvWeb, :view
  alias VutuvWeb.Api.FolloweeView

  def render("index.json", %{user_connections: user_connections}) do
    %{data: render_many(user_connections, FolloweeView, "followee.json")}
  end

  def render("show.json", %{user_connection: user_connection}) do
    %{data: render_one(user_connection, FolloweeView, "followee.json")}
  end

  def render("followee.json", %{followee: user_connection}) do
    %{id: user_connection.id}
  end
end

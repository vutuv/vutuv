defmodule VutuvWeb.Api.FollowerView do
  use VutuvWeb, :view
  alias VutuvWeb.Api.FollowerView

  def render("index.json", %{user_connections: user_connections}) do
    %{data: render_many(user_connections, FollowerView, "follower.json")}
  end

  def render("show.json", %{user_connection: user_connection}) do
    %{data: render_one(user_connection, FollowerView, "follower.json")}
  end

  def render("follower.json", %{follower: user_connection}) do
    %{id: user_connection.id}
  end
end

defmodule VutuvWeb.Api.FollowerController do
  use VutuvWeb, :controller

  alias Vutuv.{UserConnections, UserProfiles}

  action_fallback VutuvWeb.Api.FallbackController

  def index(conn, %{"user_slug" => slug}) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    user_connections = UserConnections.list_user_connections(user, :followers)
    render(conn, "index.json", user: user, user_connections: user_connections)
  end
end

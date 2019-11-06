defmodule VutuvWeb.Api.UserTagController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{Tags, Tags.UserTag, UserProfiles, UserProfiles.User}

  action_fallback VutuvWeb.Api.FallbackController

  def action(conn, _), do: auth_action_slug(conn, __MODULE__, [:index])

  def index(conn, %{"user_slug" => slug}, %User{slug: slug} = current_user) do
    user_tags = Tags.list_user_tags(current_user)
    render(conn, "index.json", user_tags: user_tags, user: current_user)
  end

  def index(conn, %{"user_slug" => slug}, _current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    user_tags = Tags.list_user_tags(user)
    render(conn, "index.json", user_tags: user_tags, user: user)
  end

  def create(conn, %{"user_tag" => user_tag_params}, current_user) do
    with {:ok, %UserTag{} = user_tag} <- Tags.create_user_tag(current_user, user_tag_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_user_path(conn, :show, current_user))
      |> render("show.json", user_tag: user_tag)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    user_tag = Tags.get_user_tag!(current_user, id)

    with {:ok, %UserTag{}} <- Tags.delete_user_tag(user_tag) do
      send_resp(conn, :no_content, "")
    end
  end
end

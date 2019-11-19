defmodule VutuvWeb.Api.PostController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{Publications, Publications.Post, UserProfiles, UserProfiles.User}

  action_fallback VutuvWeb.Api.FallbackController

  def action(conn, _), do: auth_action_slug(conn, __MODULE__, [:index, :show])

  def index(conn, %{"user_slug" => slug}, %User{slug: slug} = current_user) do
    posts = Publications.list_posts(current_user)
    render(conn, "index.json", posts: posts, user: current_user)
  end

  def index(conn, %{"user_slug" => slug}, current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    posts = Publications.list_posts(user, current_user)
    render(conn, "index.json", posts: posts, user: user)
  end

  def create(conn, %{"post" => post_params}, current_user) do
    with {:ok, %Post{} = post} <- Publications.create_post(current_user, post_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_user_post_path(conn, :show, current_user, post))
      |> render("show.json", post: post)
    end
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, %User{slug: slug} = current_user) do
    post = Publications.get_post!(current_user, id)
    render(conn, "show.json", post: post, user: current_user)
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    post = Publications.get_post!(user, id, current_user)
    render(conn, "show.json", post: post, user: user)
  end

  def update(conn, %{"id" => id, "post" => post_params}, current_user) do
    post = Publications.get_post!(current_user, id)

    with {:ok, %Post{} = post} <- Publications.update_post(post, post_params) do
      render(conn, "show.json", post: post)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    post = Publications.get_post!(current_user, id)

    with {:ok, %Post{}} <- Publications.delete_post(post) do
      send_resp(conn, :no_content, "")
    end
  end
end

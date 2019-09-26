defmodule VutuvWeb.Api.UserController do
  use VutuvWeb, :controller

  import VutuvWeb.Api.Authorize

  alias Phauxth.Log
  alias Vutuv.{UserProfiles, Publications}

  action_fallback VutuvWeb.Api.FallbackController

  def action(conn, _) do
    if action_name(conn) in [:index, :create, :show] do
      apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
    else
      auth_action_slug(conn, __MODULE__)
    end
  end

  def index(conn, _, _current_user) do
    users = UserProfiles.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}, _current_user) do
    with {:ok, user} <- UserProfiles.create_user(user_params) do
      Log.info(%Log{user: user.id, message: "user created"})

      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"slug" => slug}, %{"slug" => slug} = current_user) do
    user =
      UserProfiles.with_associated_data(current_user, [
        :email_addresses,
        :tags,
        :followers,
        :followees
      ])

    posts = Publications.list_posts(current_user)
    render(conn, "show.json", user: user, posts: posts)
  end

  def show(conn, %{"slug" => slug}, current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})

    user =
      UserProfiles.with_associated_data(user, [:email_addresses, :tags, :followers, :followees])

    posts = Publications.list_posts(user, current_user)
    render(conn, "show.json", user: user, posts: posts)
  end

  def update(conn, %{"user" => user_params}, current_user) do
    with {:ok, user} <- UserProfiles.update_user(current_user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, _, user) do
    {:ok, _user} = UserProfiles.delete_user(user)
    send_resp(conn, :no_content, "")
  end
end

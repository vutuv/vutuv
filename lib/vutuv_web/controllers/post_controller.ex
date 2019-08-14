defmodule VutuvWeb.PostController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{Accounts, Accounts.User, Socials, Socials.Post}

  @dialyzer {:nowarn_function, new: 3}

  def action(conn, _) do
    if action_name(conn) in [:index, :show] do
      apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
    else
      auth_action_slug(conn, __MODULE__)
    end
  end

  def index(conn, %{"user_slug" => slug}, %User{slug: slug} = current_user) do
    posts = Socials.list_posts(current_user)
    render(conn, "index.html", posts: posts, user: current_user)
  end

  def index(conn, %{"user_slug" => slug}, current_user) do
    user = Accounts.get_user!(%{"slug" => slug})
    posts = Socials.list_posts(user, current_user)
    render(conn, "index.html", posts: posts, user: user)
  end

  def new(conn, _params, _current_user) do
    changeset = Socials.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}, current_user) do
    case Socials.create_post(current_user, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, gettext("Post created successfully."))
        |> redirect(to: Routes.user_post_path(conn, :show, current_user, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, %User{slug: slug} = current_user) do
    post = Socials.get_post!(current_user, id)
    render(conn, "show.html", post: post, user: current_user)
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, current_user) do
    user = Accounts.get_user!(%{"slug" => slug})
    post = Socials.get_post!(user, id, current_user)
    render(conn, "show.html", post: post, user: user)
  end

  def edit(conn, %{"id" => id}, current_user) do
    post = Socials.get_post!(current_user, id)
    changeset = Socials.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}, current_user) do
    post = Socials.get_post!(current_user, id)

    case Socials.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, gettext("Post updated successfully."))
        |> redirect(to: Routes.user_post_path(conn, :show, current_user, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    post = Socials.get_post!(current_user, id)
    {:ok, _post} = Socials.delete_post(post)

    conn
    |> put_flash(:info, gettext("Post deleted successfully."))
    |> redirect(to: Routes.user_post_path(conn, :index, current_user))
  end
end

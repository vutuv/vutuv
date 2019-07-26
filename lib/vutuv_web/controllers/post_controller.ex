defmodule VutuvWeb.PostController do
  use VutuvWeb, :controller

  import VutuvWeb.AuthorizeConn

  alias Vutuv.{Accounts.User, Socials, Socials.Post, Socials.Authorize}

  @dialyzer {:nowarn_function, new: 3}

  def action(conn, _) do
    if action_name(conn) in [:index, :show] do
      apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
    else
      auth_action_slug(conn, __MODULE__)
    end
  end

  def index(conn, params, current_user) do
    {user, posts} = Authorize.list_user_posts(params, current_user)
    render(conn, "index.html", posts: posts, user: user)
  end

  def new(conn, _params, _current_user) do
    changeset = Socials.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}, current_user) do
    case Socials.create_post(current_user, post_params) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.user_post_path(conn, :index, current_user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, params, current_user) do
    case Authorize.get_user_post(params, current_user) do
      {%User{} = user, %Post{} = post} ->
        render(conn, "show.html", post: post, user: user)

      _ ->
        conn
        |> put_view(VutuvWeb.ErrorView)
        |> render(:"404")
    end
  end

  def edit(conn, %{"id" => id}, user) do
    case Socials.get_post(user, %{"id" => id}) do
      %Post{} = post ->
        changeset = Socials.change_post(post)
        render(conn, "edit.html", post: post, changeset: changeset)

      _ ->
        unauthorized(conn, user)
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}, user) do
    if post = Socials.get_post(user, %{"id" => id}) do
      do_update(conn, post, post_params, user)
    else
      unauthorized(conn, user)
    end
  end

  defp do_update(conn, post, post_params, user) do
    case Socials.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.user_post_path(conn, :show, user, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    case Socials.get_post(user, %{"id" => id}) do
      %Post{} = post ->
        {:ok, _post} = Socials.delete_post(post)

        conn
        |> put_flash(:info, "Post deleted successfully.")
        |> redirect(to: Routes.user_post_path(conn, :index, user))

      _ ->
        unauthorized(conn, user)
    end
  end
end

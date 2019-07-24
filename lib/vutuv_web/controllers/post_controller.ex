defmodule VutuvWeb.PostController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{Accounts, Socials, Socials.Post}

  @dialyzer {:nowarn_function, new: 3}

  def action(conn, _) do
    if action_name(conn) in [:index, :show] do
      apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
    else
      auth_action_slug(conn, __MODULE__)
    end
  end

  def index(conn, %{"user_slug" => user_slug}, user) do
    user = get_user(user, user_slug)
    posts = Socials.list_posts(user)
    render(conn, "index.html", posts: posts, user: user)
  end

  def new(conn, _params, _user) do
    changeset = Socials.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}, user) do
    case Socials.create_post(user, post_params) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.user_post_path(conn, :index, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "user_slug" => user_slug}, user) do
    user = get_user(user, user_slug)

    case Socials.get_post(user, %{"id" => id}) do
      nil ->
        conn
        |> put_view(VutuvWeb.ErrorView)
        |> render(:"404")

      post ->
        post = Socials.post_associated_data(post, [:tags])
        render(conn, "show.html", post: post, user: user)
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

  defp get_user(%{slug: slug} = user, slug), do: user
  defp get_user(_user, slug), do: Accounts.get_user(%{"slug" => slug})
end

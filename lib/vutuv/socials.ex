defmodule Vutuv.Socials do
  @moduledoc """
  The Socials context.
  """

  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.{Accounts.User, Repo, Socials.Post, Tags.Tag}

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns a list of posts.
  """
  @spec list_posts() :: [Post.t()]
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Returns a list of posts for a user.
  """
  @spec list_posts(User.t()) :: [Post.t()]
  def list_posts(%User{} = user) do
    user |> assoc(:posts) |> post_query() |> Repo.all()
  end

  @doc """
  Returns a list of user posts filtered based on the posts' visibility_level.
  """
  @spec list_posts(User.t(), User.t() | nil) :: [Post.t()]
  def list_posts(%User{} = user, current_user) do
    visibility_level = get_visibility_level(user, current_user)

    user
    |> assoc(:posts)
    |> where([p], p.visibility_level in ^visibility_level)
    |> post_query()
    |> Repo.all()
  end

  @doc """
  Gets a specific user's post. Raises error if no post found.
  """
  @spec get_post!(User.t(), integer) :: Post.t() | no_return
  def get_post!(%User{} = user, id) do
    user
    |> assoc(:posts)
    |> where([p], p.id == ^id)
    |> post_query()
    |> Repo.one!()
  end

  @doc """
  Gets a user's post filtered based on the post's visibility_level.
  Raises error if no post found.
  """
  @spec get_post!(User.t(), integer, User.t() | nil) :: Post.t() | no_return
  def get_post!(%User{} = user, id, current_user) do
    visibility_level = get_visibility_level(user, current_user)

    user
    |> assoc(:posts)
    |> where([p], p.id == ^id and p.visibility_level in ^visibility_level)
    |> post_query()
    |> Repo.one!()
  end

  defp post_query(post) do
    post
    |> join(:left, [p], _ in assoc(p, :tags))
    |> preload([_, t], tags: t)
  end

  defp get_visibility_level(_user, nil), do: ["public"]

  defp get_visibility_level(user, current_user) do
    followers = Repo.preload(user, :followers).followers

    if current_user.id in Enum.map(followers, & &1.id) do
      ["public", "followers"]
    else
      ["public"]
    end
  end

  @doc """
  Creates a post.
  """
  @spec create_post(User.t(), map) :: {:ok, Post.t()} | changeset_error
  def create_post(user, attrs \\ %{}) do
    user
    |> build_assoc(:posts)
    |> Post.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.
  """
  @spec update_post(Post.t(), map) :: {:ok, Post.t()} | changeset_error
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Post.
  """
  @spec delete_post(Post.t()) :: {:ok, Post.t()} | changeset_error
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.
  """
  @spec change_post(Post.t()) :: Ecto.Changeset.t()
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end

  @doc """
  Adds an association between a post and existing tags.
  """
  @spec add_post_tags(Post.t(), list) :: {:ok, Post.t()} | changeset_error
  def add_post_tags(%Post{} = post, tag_ids) do
    tags = Tag |> where([t], t.id in ^tag_ids) |> Repo.all()
    post |> Repo.preload([:tags]) |> Post.post_tag_changeset(tags) |> Repo.update()
  end
end

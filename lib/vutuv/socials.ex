defmodule Vutuv.Socials do
  @moduledoc """
  The Socials context.
  """

  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.{Accounts.User, Repo, Socials.Post}

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  @spec list_posts() :: [Post.t()]
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Returns a list of posts for the user.
  """
  @spec list_posts(User.t()) :: [Post.t()]
  def list_posts(user) do
    Repo.all(assoc(user, :posts))
  end

  @doc """
  Gets a single post.

  ## Examples

      iex> get_post(123)
      %Post{}

      iex> get_post(456)
      nil

  """
  @spec get_post(integer) :: Post.t() | nil
  def get_post(id), do: Repo.get(Post, id)

  @doc """
  Creates a post.
  """
  @spec create_post(User.t(), map) :: {:ok, Post.t()} | changeset_error
  def create_post(user, attrs \\ %{}) do
    user
    |> build_assoc(:posts)
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_post(Post.t(), map) :: {:ok, Post.t()} | changeset_error
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_post(Post.t()) :: {:ok, Post.t()} | changeset_error
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  @spec change_post(Post.t()) :: Ecto.Changeset.t()
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end
end

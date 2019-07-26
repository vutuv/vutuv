defmodule Vutuv.Socials.Authorize do
  @moduledoc """
  Functions for authorizing posts.
  """

  alias Vutuv.{Accounts, Accounts.User, Socials, Socials.Post}

  @doc """
  Lists a user's visible posts.
  """
  @spec list_user_posts(map, User.t() | nil) :: {User.t() | nil, [Post.t()]}
  def list_user_posts(%{"user_slug" => slug}, %User{slug: slug} = user) do
    {user, Socials.list_posts(user)}
  end

  def list_user_posts(%{"user_slug" => slug}, nil) do
    case Accounts.get_user(%{"slug" => slug}) do
      %User{} = user -> {user, Socials.list_posts(user, ["public"])}
      _ -> {nil, []}
    end
  end

  def list_user_posts(%{"user_slug" => slug}, current_user) do
    case Accounts.get_user(%{"slug" => slug}) do
      %User{} = user ->
        {user, Socials.list_posts(user, get_visibility_level(current_user, user))}

      _ ->
        nil
    end
  end

  @doc """
  Returns a user's visible posts.
  """
  @spec get_user_post(map, User.t() | nil) :: {User.t() | nil, Post.t() | nil}
  def get_user_post(%{"id" => id, "user_slug" => slug}, %User{slug: slug} = user) do
    {user, Socials.get_post(user, %{"id" => id})}
  end

  def get_user_post(%{"id" => id, "user_slug" => slug}, nil) do
    case Accounts.get_user(%{"slug" => slug}) do
      %User{} = user -> {user, Socials.get_post(user, %{"id" => id}, ["public"])}
      _ -> {nil, nil}
    end
  end

  def get_user_post(%{"id" => id, "user_slug" => slug}, current_user) do
    case Accounts.get_user(%{"slug" => slug}) do
      %User{} = user ->
        {user, Socials.get_post(user, %{"id" => id}, get_visibility_level(current_user, user))}

      _ ->
        nil
    end
  end

  defp get_visibility_level(current_user, other_user) do
    if is_follower?(current_user, other_user) do
      ["public", "followers"]
    else
      ["public"]
    end
  end

  defp is_follower?(current_user, other_user) do
    follower_ids =
      other_user |> Accounts.list_user_connections(:followers, nil) |> Enum.map(& &1.id)

    current_user.id in follower_ids
  end
end

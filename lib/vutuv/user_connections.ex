defmodule Vutuv.UserConnections do
  @moduledoc """
  The UserConnections context.
  """

  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.{Repo, UserConnections.UserConnection, UserProfiles.User}

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns a user's followers and followees in a paginated struct.
  """
  @spec paginate_user_connections(User.t(), map, :followees | :followers) :: Scrivener.Page.t()
  def paginate_user_connections(%User{} = user, attrs, :followees) do
    user |> assoc(:followees) |> preload(:followee) |> Repo.paginate(attrs)
  end

  def paginate_user_connections(%User{} = user, attrs, :followers) do
    user |> assoc(:followers) |> preload(:follower) |> Repo.paginate(attrs)
  end

  @doc """
  Returns the latest `number` followees of a user.
  """
  @spec latest_followees(integer) :: Ecto.Query.t()
  def latest_followees(number) do
    from uc in UserConnection,
      join: f in assoc(uc, :followee),
      order_by: [desc: :inserted_at],
      limit: ^number
  end

  @doc """
  Returns the latest `number` followers of a user.
  """
  @spec latest_followers(integer) :: Ecto.Query.t()
  def latest_followers(number) do
    from uc in UserConnection,
      join: f in assoc(uc, :follower),
      order_by: [desc: :inserted_at],
      limit: ^number
  end

  @doc """
  Gets a user connection - between followee and follower.
  """
  @spec get_user_connection!(map | integer) :: UserConnection.t() | no_return
  def get_user_connection!(%{"followee_id" => followee_id, "follower_id" => follower_id}) do
    Repo.get_by!(UserConnection, followee_id: followee_id, follower_id: follower_id)
  end

  def get_user_connection!(id), do: Repo.get!(UserConnection, id)

  def get_user_connection(%User{id: followee_id}, %User{id: follower_id}) do
    Repo.get_by(UserConnection, followee_id: followee_id, follower_id: follower_id)
  end

  @doc """
  Adds a user_connection between a follower and a followee.
  """
  @spec create_user_connection(map) :: {:ok, UserConnection.t()} | changeset_error
  def create_user_connection(attrs) do
    %UserConnection{}
    |> UserConnection.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a user_connection.
  """
  @spec delete_user_connection(UserConnection.t()) :: {:ok, UserConnection.t()} | changeset_error
  def delete_user_connection(%UserConnection{} = user_connection) do
    Repo.delete(user_connection)
  end

  @doc """
  Returns the number of a user's followers.
  """
  @spec follower_count(User.t()) :: integer
  def follower_count(%User{} = user) do
    query = from u in UserConnection, where: u.followee_id == ^user.id
    Repo.aggregate(query, :count, :id)
  end
end

defmodule Vutuv.UserConnections do
  @moduledoc """
  The UserConnections context.
  """

  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.{Repo, UserProfiles.User}

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns a user's followers and followees in a paginated struct.
  """
  @spec paginate_user_connections(User.t(), map, :followers | :followees) :: Scrivener.Page.t()
  def paginate_user_connections(%User{} = user, attrs, connection) do
    user |> assoc(connection) |> Repo.paginate(attrs)
  end

  @doc """
  Adds followees to a user.

  If successful, the users in the followee_ids list will be added to the
  user's followees. In addition, the user will be added to the followers
  list of the followees.
  """
  @spec add_followees(User.t(), list) :: {:ok, User.t()} | changeset_error
  def add_followees(%User{} = user, followee_ids) do
    followees = User |> where([l], l.id in ^followee_ids) |> Repo.all()

    user
    |> Repo.preload([:followees])
    |> User.followee_changeset(followees)
    |> Repo.update()
  end
end

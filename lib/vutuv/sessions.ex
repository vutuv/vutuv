defmodule Vutuv.Sessions do
  @moduledoc """
  The Sessions context.
  """

  import Ecto.Query, warn: false

  alias Vutuv.{UserProfiles.User, Repo, Sessions.Session}

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns a list of sessions for the user.
  """
  @spec list_sessions(User.t()) :: [Session.t()]
  def list_sessions(%User{} = user) do
    sessions = Repo.preload(user, :sessions).sessions
    Enum.filter(sessions, &(DateTime.compare(&1.expires_at, DateTime.utc_now()) == :gt))
  end

  @doc """
  Gets a single valid session. Returns nil if no session found.
  """
  @spec get_session(integer) :: Session.t() | nil
  def get_session(id) do
    now = DateTime.utc_now()
    Repo.get(from(s in Session, where: s.expires_at > ^now), id)
  end

  @doc """
  Creates a session.
  """
  @spec create_session(map) :: {:ok, Session.t()} | changeset_error
  def create_session(attrs \\ %{}) do
    %Session{} |> Session.changeset(attrs) |> Repo.insert()
  end

  @doc """
  Deletes a session.
  """
  @spec delete_session(Session.t()) :: {:ok, Session.t()} | changeset_error
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Deletes all a user's sessions.
  """
  @spec delete_user_sessions(User.t()) :: tuple
  def delete_user_sessions(%User{} = user) do
    Repo.delete_all(from(s in Session, where: s.user_id == ^user.id))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  @spec change_session(Session.t()) :: Ecto.Changeset.t()
  def change_session(%Session{} = session) do
    Session.changeset(session, %{})
  end
end

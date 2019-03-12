defmodule Vutuv.Sessions do
  @moduledoc """
  The Sessions context.
  """

  import Ecto.Query, warn: false

  alias Vutuv.Repo
  alias Vutuv.Accounts.User
  alias Vutuv.Sessions.Session

  @doc """
  Returns a list of sessions for the user.
  """
  def list_sessions(%User{} = user) do
    sessions = Repo.preload(user, :sessions).sessions
    Enum.filter(sessions, &(&1.expires_at > DateTime.utc_now()))
  end

  @doc """
  Gets a single valid session.
  """
  def get_session(id) do
    now = DateTime.utc_now()
    Repo.get(from(s in Session, where: s.expires_at > ^now), id)
  end

  @doc """
  Creates a session.
  """
  def create_session(attrs \\ %{}) do
    %Session{} |> Session.changeset(attrs) |> Repo.insert()
  end

  @doc """
  Deletes a session.
  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Deletes all a user's sessions.
  """
  def delete_user_sessions(%User{} = user) do
    Repo.delete_all(from(s in Session, where: s.user_id == ^user.id))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_session(%Session{} = session) do
    Session.changeset(session, %{})
  end
end

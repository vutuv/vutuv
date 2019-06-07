defmodule Vutuv.SessionsTest do
  use Vutuv.DataCase

  alias Vutuv.{Accounts, Sessions, Sessions.Session}

  setup do
    attrs = %{
      "email" => "fred@example.com",
      "password" => "reallyHard2gue$$",
      "profile" => %{
        "gender" => "male",
        "full_name" => "fred frederickson"
      }
    }

    {:ok, user} = Accounts.create_user(attrs)
    {:ok, user: user}
  end

  def fixture(:session, attrs) do
    {:ok, session} = Sessions.create_session(attrs)
    session
  end

  describe "read session data" do
    test "list_sessions/1 returns all of a user's sessions", %{user: user} do
      session = fixture(:session, %{user_id: user.id})
      assert Sessions.list_sessions(user) == [session]
    end

    test "get returns the session with given id", %{user: user} do
      session = fixture(:session, %{user_id: user.id})
      assert Sessions.get_session(session.id) == session
    end

    test "change_session/1 returns a session changeset", %{user: user} do
      session = fixture(:session, %{user_id: user.id})
      assert %Ecto.Changeset{} = Sessions.change_session(session)
    end
  end

  describe "write session data" do
    test "create_session/1 with valid data creates a session", %{user: user} do
      create_attrs = %{user_id: user.id}
      assert {:ok, %Session{} = session} = Sessions.create_session(create_attrs)
      assert session.user_id == user.id
      assert DateTime.diff(session.expires_at, DateTime.utc_now()) == 86400
    end

    test "create_session/1 with invalid data returns error changeset" do
      invalid_attrs = %{user_id: nil}
      assert {:error, %Ecto.Changeset{}} = Sessions.create_session(invalid_attrs)
    end

    test "create_session/1 with custom max_age / expiry time", %{user: user} do
      create_attrs = %{user_id: user.id, max_age: 7200}
      assert {:ok, %Session{} = session} = Sessions.create_session(create_attrs)
      assert session.user_id == user.id
      assert DateTime.diff(session.expires_at, DateTime.utc_now()) == 7200
    end
  end

  describe "delete session data" do
    test "delete_session/1 deletes the session", %{user: user} do
      session = fixture(:session, %{user_id: user.id})
      assert {:ok, %Session{}} = Sessions.delete_session(session)
      refute Sessions.get_session(session.id)
    end

    test "delete_user_sessions/1 deletes all of a user's sessions", %{user: user} do
      fixture(:session, %{user_id: user.id})
      fixture(:session, %{user_id: user.id})
      assert {2, _} = Sessions.delete_user_sessions(user)
      assert Sessions.list_sessions(user) == []
    end
  end
end

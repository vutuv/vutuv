defmodule Vutuv.Auth do
  import Plug.Conn
  import Ecto.Query

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get(Vutuv.User, user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def login_by_email(conn, email, _opts) do
    email
    |> String.downcase
    
    user =
      Vutuv.User
      |> join(:inner, [u], e in assoc(u, :emails))
      |> where([u, e], e.value == ^email)
      |> Vutuv.Repo.one()

    cond do
      user != nil ->
        {:ok, Vutuv.MagicLink.gen_magic_link(user), conn}
      user == nil ->
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    conn
    |> configure_session(drop: true)
    |> delete_session(:user_id)
  end
end

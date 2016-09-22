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

    if user == nil, do: {:error, :not_found, conn}, else: {:ok, Vutuv.MagicLinkHelpers.gen_magic_link(user, "login"), conn}
  end

  def login_by_facebook(params) do
    fb_id = params["id"]
    user = Vutuv.Repo.one(from u in Vutuv.User, join: o in assoc(u, :oauth_providers), where: o.provider_id == ^fb_id and o.provider == "facebook")

    if user == nil, do: {:error, :not_found, params}, else: {:ok, user}
  end

  def logout(conn) do
    conn
    |> configure_session(drop: true)
    |> delete_session(:user_id)
  end
end

defmodule Vutuv.UserController do
  use Vutuv.Web, :controller
  plug :authenticate when action in [:index, :show]
  import Vutuv.UserHelpers

  alias Vutuv.User
  alias Vutuv.Email
  alias Vutuv.Group
  alias Vutuv.Connection

  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset =
      User.changeset(%User{})
      |> Ecto.Changeset.put_assoc(:emails, [%Email{}])
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    groups =
      for name <- ["Friends and Family", "Business acquaintances"] do
        Group.changeset(%Group{}, %{name: name})
      end

    changeset =
      User.changeset(%User{}, user_params)
      |> Ecto.Changeset.put_assoc(:groups, groups)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Vutuv.Auth.login(user)
        |> put_flash(:info, "User #{full_name(user)} created successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user =
      Repo.get!(User, id)
      |> Repo.preload([:groups, :emails,
                      followee_connections:
                        {Connection.latest(5), [:followee]},
                      follower_connections:
                        {Connection.latest(5), [:follower]}])

    followers_count = Repo.one(from c in Connection, where: c.follower_id == ^user.id, select: count("*"))
    followees_count = Repo.one(from c in Connection, where: c.followee_id == ^user.id, select: count("*"))

    changeset = Connection.changeset(%Connection{},%{follower_id: conn.assigns.current_user.id, followee_id: user.id})

    emails_counter = length(user.emails)

    conn
    |> assign(:page_title, full_name(user))
    |> assign(:user, user)
    |> render("show.html", changeset: changeset, emails_counter: emails_counter, followers_count: followers_count, followees_count: followees_count)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id) |> Repo.preload([:emails])
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end

  def follow_back(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    changeset = Connection.changeset(%Connection{},%{follower_id: conn.assigns.current_user.id, followee_id: user.id})

    conn
    |> assign(:page_title, full_name(user))
    |> assign(:user, user)

    case Repo.insert(changeset) do
      {:ok, _connection} ->
        conn
        |> put_flash(:info, "You follow back #{full_name(user)}.")
        |> redirect(to: user_path(conn, :show, conn.assigns.current_user))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Couldn't follow back to #{full_name(user)}.")
        |> redirect(to: user_path(conn, :show, conn.assigns.current_user))
    end
  end

  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end
end

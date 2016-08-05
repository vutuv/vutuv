defmodule Vutuv.UserController do
  use Vutuv.Web, :controller
  plug :resolve_slug when action in [:edit, :update, :index, :show]
  plug :logged_in? when action in [:index, :show]
  plug :auth when action in [:edit, :update]
  import Vutuv.UserHelpers

  alias Vutuv.Slug
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
    slugs = 
      if(user_params["first_name"] != nil and user_params["last_name"] != nil) do
        struct = %User{first_name: user_params["first_name"], last_name: user_params["last_name"]}

        slug = Slugger.slugify_downcase(struct, ?.)

        user_count = Repo.one(from u in User, 
          where: u.first_name == ^user_params["first_name"]
          and u.last_name == ^user_params["last_name"],
          select: count("*"))
        slug=
          if(user_count>0) do 
            slug<>Integer.to_string(user_count) 
          else
            slug
          end

        [Slug.changeset(%Slug{}, %{value: slug})]
      end
    changeset = User.changeset(%User{}, user_params)
    |> Ecto.Changeset.put_assoc(:groups, groups)
    |> Ecto.Changeset.put_assoc(:slugs, slugs)
    |> Ecto.Changeset.put_change(:active_slug, slug)

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

  def show(conn, _params) do
    user =
      Repo.get!(User, conn.assigns[:user_id])
      |> Repo.preload([:groups, :emails, :user_skills,
                      :user_urls, :user_dates, :phone_numbers,
                      followee_connections:
                        {Connection.latest(5), [:followee]},
                      follower_connections:
                        {Connection.latest(5), [:follower]},
                      slugs: from(s in Vutuv.Slug, order_by: [desc: s.updated_at], limit: 1)])

    followees_count = Repo.one(from c in Connection, where: c.follower_id == ^user.id, select: count("followee_id"))
    followers_count = Repo.one(from c in Connection, where: c.followee_id == ^user.id, select: count("follower_id"))

    changeset = Connection.changeset(%Connection{},%{follower_id: conn.assigns.current_user.id, followee_id: user.id})

    emails_counter = length(user.emails)

    conn
    |> assign(:page_title, full_name(user))
    |> assign(:user, user)
    |> assign(:user_show, true)
    |> render("show.html", changeset: changeset, emails_counter: emails_counter, followers_count: followers_count, followees_count: followees_count)
  end

  # Function calls helper function in Connection to check
  # if a connection exists between given user id and current user
  def visitor_is_follower?(conn, id) do
    Connection.contains(id,conn.assigns.current_user.id)
  end

  def edit(conn, _params) do
    user = Repo.get!(User, conn.assigns[:user_id]) |> Repo.preload([:emails, :slugs])
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = Repo.get!(User, conn.assigns[:user_id])
    |> Repo.preload([:emails,:slugs])
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

  def insert_slug(conn, %{"id" => id, "params" => params}) do
    user = Repo.get!(User, id)
    slug_changeset = Slug.changeset(%Slug{user_id: id}, params)
    case Repo.insert(slug_changeset) do
      {:ok, _slug} ->
        conn
        |> put_flash(:info, "Slug updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, _changeset} ->
        changeset = User.changeset(user)
        render(conn, "edit.html", user: user, changeset: changeset, slug_changeset: slug_changeset)
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

  def resolve_slug(conn, _opts) do
    case conn.params do
      %{"slug" => slug} ->
        case Repo.one(from s in Slug, where: s.value == ^slug, select: s.user_id) do
          nil  -> invalid_slug(conn)
          user_id ->
            user = Repo.get!(Vutuv.User, user_id)
            if(user.active_slug != slug) do
              redirect(conn, to: user_path(conn, :show, user))
            else
              assign(conn, :user_id, user_id)
            end
        end
      _ -> invalid_slug(conn)
    end
  end

  def invalid_slug(conn) do
    conn
    |> put_status(:not_found)
    |> render(Vutuv.ErrorView, "404.html")
    |> halt
  end

  defp logged_in?(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end

  defp auth(conn, _opts) do
    case conn.params do
      %{"slug" => slug} ->
        case Repo.one(from s in Slug, where: s.value == ^slug, select: s.user_id) do
          nil  -> invalid_slug(conn)
          user_id ->
            if(user_id == conn.assigns[:current_user].id) do
              conn
            else
              conn
              |> put_status(403)
              |> render(Vutuv.ErrorView, "403.html")
              |> halt
            end
        end
      _ -> invalid_slug(conn)
    end
  end
end

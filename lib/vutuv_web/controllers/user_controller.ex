defmodule VutuvWeb.UserController do
  use VutuvWeb, :controller

  import VutuvWeb.AuthorizeConn

  alias Phauxth.Log
  alias Vutuv.{Accounts, Accounts.User, Socials.Authorize}

  @dialyzer {:nowarn_function, new: 3}

  def action(conn, _) do
    if action_name(conn) in [:index, :new, :create, :show] do
      apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
    else
      auth_action_slug(conn, __MODULE__)
    end
  end

  def index(conn, params, _current_user) do
    page = Accounts.paginate_users(params)
    render(conn, "index.html", users: page.entries, page: page)
  end

  def new(conn, _, %User{} = user) do
    redirect(conn, to: Routes.user_path(conn, :show, user))
  end

  def new(conn, _, _current_user) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}, _current_user) do
    user_params =
      conn |> get_req_header("accept-language") |> add_accept_language_to_params(user_params)

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Log.info(%Log{user: user.id, message: "user created"})
        email = user_params["email"]

        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.confirm_path(conn, :new, email: email))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"slug" => slug}, current_user) do
    case Authorize.list_user_posts(%{"user_slug" => slug}, current_user) do
      {%User{} = user, posts} ->
        user = Accounts.with_associated_data(user, [:email_addresses, :tags])
        followers = Accounts.list_user_connections(user, :followers, 4)
        leaders = Accounts.list_user_connections(user, :leaders, 4)

        render(conn, "show.html", user: user, followers: followers, leaders: leaders, posts: posts)

      _ ->
        conn
        |> put_view(VutuvWeb.ErrorView)
        |> render(:"404")
    end
  end

  def edit(conn, _, user) do
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}, user) do
    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, _, user) do
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> delete_session(:phauxth_session_id)
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.session_path(conn, :new))
  end

  defp add_accept_language_to_params(accept_language, %{"user" => _} = user_params) do
    al = if accept_language == [], do: "", else: hd(accept_language)
    put_in(user_params, ["user", "accept_language"], al)
  end

  defp add_accept_language_to_params(_, user_params), do: user_params
end

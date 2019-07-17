defmodule VutuvWeb.UserController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Phauxth.Log
  alias Vutuv.{Accounts, Accounts.User, Socials}

  @dialyzer {:nowarn_function, new: 2}

  plug :slug_check when action in [:edit, :update, :delete]

  def index(conn, _) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, _) do
    redirect(conn, to: Routes.user_path(conn, :show, user))
  end

  def new(conn, _) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
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

  def show(%Plug.Conn{assigns: %{current_user: %{slug: slug} = user}} = conn, %{"slug" => slug}) do
    email_addresses = Accounts.list_email_addresses(user)
    posts = Socials.list_posts(user)
    render(conn, "show.html", user: user, email_addresses: email_addresses, posts: posts)
  end

  def show(%Plug.Conn{assigns: %{current_user: _user}} = conn, %{"slug" => slug}) do
    case Accounts.get_user(%{"slug" => slug}) do
      nil ->
        conn
        |> put_view(VutuvWeb.ErrorView)
        |> render(:"404")

      user ->
        email_addresses = Accounts.list_email_addresses(user, :public)
        posts = Socials.list_posts(user, :public)
        render(conn, "show.html", user: user, email_addresses: email_addresses, posts: posts)
    end
  end

  def edit(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params}) do
    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
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

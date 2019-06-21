defmodule VutuvWeb.UserController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Phauxth.Log
  alias Vutuv.{Accounts, Accounts.User}
  alias VutuvWeb.{Auth.Otp, Email}

  @dialyzer {:nowarn_function, new: 2}

  plug :id_check when action in [:edit, :update, :delete]

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

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Log.info(%Log{user: user.id, message: "user created"})
        code = Otp.create()
        Email.confirm_request(email, code)

        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.confirm_path(conn, :new, email: email))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    user = if user && id == to_string(user.id), do: user, else: Accounts.get_user(id)
    render(conn, "show.html", user: user, profile: user.profile)
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
end

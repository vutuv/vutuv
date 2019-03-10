defmodule VutuvWeb.UserController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Phauxth.Log
  alias Vutuv.{Accounts, Accounts.User, Repo, Biographies, Biographies.Profile, Socials, Socials.Post}
  alias VutuvWeb.{Auth.Token, Email}

  # the following plugs are defined in the controllers/authorize.ex file
  plug :user_check when action in [:index, :show]
  plug :id_check when action in [:edit, :update, :delete]

  def index(conn, _) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    key = Token.sign(%{"email" => email})
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Log.info(%Log{user: user.id, message: "user created"})

        Email.confirm_request(email, key)

        #create profile
        profile = Ecto.build_assoc(user, :profiles, %{gender: user_params["gender"], first_name: user_params["first_name"], last_name: user_params["last_name"]})
        Repo.insert!(profile)

        #create email_address
        email = Ecto.build_assoc(user, :email_addresses, %{value: user_params["email"]})
        Repo.insert!(email)

        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    user = if id == to_string(user.id), do: user, else: Accounts.get_user(id)
    
    profile = if id == to_string(user.id) do 
      profile = Biographies.get_profile!(id) 
    else 
      Repo.get!(Profile, id)
    end

    post = if id == to_string(user.id) do 
      post = Socials.get_post(id) 
    else 
      Repo.get!(Post, id)
    end

    render(conn, "show.html", user: user, profile: profile, post: post)
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

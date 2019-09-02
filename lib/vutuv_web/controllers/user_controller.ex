defmodule VutuvWeb.UserController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Phauxth.Log
  alias Vutuv.{UserProfiles, UserProfiles.User, Devices, Publications}
  alias VutuvWeb.EmailAddressController

  @dialyzer {:nowarn_function, new: 3}

  def action(conn, _) do
    if action_name(conn) in [:index, :new, :create, :show] do
      apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
    else
      auth_action_slug(conn, __MODULE__)
    end
  end

  def index(conn, params, _current_user) do
    page = UserProfiles.paginate_users(params)
    render(conn, "index.html", users: page.entries, page: page)
  end

  def new(conn, _, %User{} = user) do
    redirect(conn, to: Routes.user_path(conn, :show, user))
  end

  def new(conn, _, _current_user) do
    changeset = UserProfiles.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}, _current_user) do
    user_params =
      conn |> get_req_header("accept-language") |> add_accept_language_to_params(user_params)

    case UserProfiles.create_user(user_params) do
      {:ok, user} ->
        Log.info(%Log{user: user.id, message: "user created"})
        EmailAddressController.verify_email(conn, user_params, "confirm your account", true)

      {:error, %Ecto.Changeset{} = changeset} ->
        if Devices.duplicate_email_error?(changeset) do
          EmailAddressController.verify_email(conn, user_params, "confirm your account", false)
        else
          render(conn, "new.html", changeset: changeset)
        end
    end
  end

  def show(conn, %{"slug" => slug}, %{"slug" => slug} = current_user) do
    user = get_user_with_associations(current_user)
    posts = Publications.list_posts(current_user)
    render(conn, "show.html", user: user, posts: posts)
  end

  def show(conn, %{"slug" => slug}, current_user) do
    user = %{"slug" => slug} |> UserProfiles.get_user!() |> get_user_with_associations()
    posts = Publications.list_posts(user, current_user)
    render(conn, "show.html", user: user, posts: posts)
  end

  def edit(conn, _, user) do
    changeset = UserProfiles.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}, user) do
    case UserProfiles.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("User updated successfully."))
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, _, user) do
    {:ok, _user} = UserProfiles.delete_user(user)

    conn
    |> delete_session(:phauxth_session_id)
    |> put_flash(:info, gettext("User deleted successfully."))
    |> redirect(to: Routes.session_path(conn, :new))
  end

  defp get_user_with_associations(user) do
    UserProfiles.with_associated_data(user, [
      :email_addresses,
      :social_media_accounts,
      :tags,
      :followers,
      :leaders
    ])
  end

  defp add_accept_language_to_params(accept_language, %{"user" => _} = user_params) do
    al = if accept_language == [], do: "", else: hd(accept_language)
    put_in(user_params, ["user", "accept_language"], al)
  end

  defp add_accept_language_to_params(_, user_params), do: user_params
end

defmodule VutuvWeb.SocialMediaAccountController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{SocialNetworks, SocialNetworks.SocialMediaAccount}
  alias Vutuv.{UserProfiles, UserProfiles.User}

  @dialyzer {:nowarn_function, new: 3}

  def action(conn, _), do: auth_action_slug(conn, __MODULE__, [:index, :show])

  def index(conn, %{"user_slug" => slug}, %User{slug: slug} = current_user) do
    social_media_accounts = SocialNetworks.list_social_media_accounts(current_user)
    render(conn, "index.html", social_media_accounts: social_media_accounts, user: current_user)
  end

  def index(conn, %{"user_slug" => slug}, _current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    social_media_accounts = SocialNetworks.list_social_media_accounts(user)
    render(conn, "index.html", social_media_accounts: social_media_accounts, user: user)
  end

  def new(conn, _params, _current_user) do
    changeset = SocialNetworks.change_social_media_account(%SocialMediaAccount{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"social_media_account" => social_media_account_params}, current_user) do
    case SocialNetworks.create_social_media_account(current_user, social_media_account_params) do
      {:ok, social_media_account} ->
        conn
        |> put_flash(:info, gettext("Social media account created successfully."))
        |> redirect(
          to:
            Routes.user_social_media_account_path(conn, :show, current_user, social_media_account)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, %User{slug: slug} = current_user) do
    social_media_account = SocialNetworks.get_social_media_account!(current_user, id)
    render(conn, "show.html", social_media_account: social_media_account, user: current_user)
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, _current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    social_media_account = SocialNetworks.get_social_media_account!(user, id)
    render(conn, "show.html", social_media_account: social_media_account, user: user)
  end

  def edit(conn, %{"id" => id}, current_user) do
    social_media_account = SocialNetworks.get_social_media_account!(current_user, id)
    changeset = SocialNetworks.change_social_media_account(social_media_account)
    render(conn, "edit.html", social_media_account: social_media_account, changeset: changeset)
  end

  def update(
        conn,
        %{"id" => id, "social_media_account" => social_media_account_params},
        current_user
      ) do
    social_media_account = SocialNetworks.get_social_media_account!(current_user, id)

    case SocialNetworks.update_social_media_account(
           social_media_account,
           social_media_account_params
         ) do
      {:ok, social_media_account} ->
        conn
        |> put_flash(:info, gettext("Social media account updated successfully."))
        |> redirect(
          to:
            Routes.user_social_media_account_path(conn, :show, current_user, social_media_account)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", social_media_account: social_media_account, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    social_media_account = SocialNetworks.get_social_media_account!(current_user, id)

    {:ok, _social_media_account} =
      SocialNetworks.delete_social_media_account(social_media_account)

    conn
    |> put_flash(:info, gettext("Social media account deleted successfully."))
    |> redirect(to: Routes.user_social_media_account_path(conn, :index, current_user))
  end
end

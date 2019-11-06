defmodule VutuvWeb.Api.SocialMediaAccountController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{SocialNetworks, SocialNetworks.SocialMediaAccount}
  alias Vutuv.{UserProfiles, UserProfiles.User}

  action_fallback VutuvWeb.Api.FallbackController

  def action(conn, _), do: auth_action_slug(conn, __MODULE__, [:index, :show])

  def index(conn, %{"user_slug" => slug}, %User{slug: slug} = current_user) do
    social_media_accounts = SocialNetworks.list_social_media_accounts(current_user)
    render(conn, "index.json", social_media_accounts: social_media_accounts, user: current_user)
  end

  def index(conn, %{"user_slug" => slug}, _current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    social_media_accounts = SocialNetworks.list_social_media_accounts(user)
    render(conn, "index.json", social_media_accounts: social_media_accounts, user: user)
  end

  def create(conn, %{"social_media_account" => social_media_account_params}, current_user) do
    with {:ok, %SocialMediaAccount{} = social_media_account} <-
           SocialNetworks.create_social_media_account(current_user, social_media_account_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.api_user_social_media_account_path(conn, :show, current_user, social_media_account)
      )
      |> render("show.json", social_media_account: social_media_account)
    end
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, %User{slug: slug} = current_user) do
    social_media_account = SocialNetworks.get_social_media_account!(current_user, id)
    render(conn, "show.json", social_media_account: social_media_account, user: current_user)
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, _current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    social_media_account = SocialNetworks.get_social_media_account!(user, id)
    render(conn, "show.json", social_media_account: social_media_account, user: user)
  end

  def update(
        conn,
        %{"id" => id, "social_media_account" => social_media_account_params},
        current_user
      ) do
    social_media_account = SocialNetworks.get_social_media_account!(current_user, id)

    with {:ok, %SocialMediaAccount{} = social_media_account} <-
           SocialNetworks.update_social_media_account(
             social_media_account,
             social_media_account_params
           ) do
      render(conn, "show.json", social_media_account: social_media_account)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    social_media_account = SocialNetworks.get_social_media_account!(current_user, id)

    with {:ok, %SocialMediaAccount{}} <-
           SocialNetworks.delete_social_media_account(social_media_account) do
      send_resp(conn, :no_content, "")
    end
  end
end

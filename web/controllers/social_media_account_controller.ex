defmodule Vutuv.SocialMediaAccountController do
  use Vutuv.Web, :controller
  alias Vutuv.SocialMediaAccount

  plug Vutuv.Plug.AuthUser when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    social_media_accounts = Repo.all(SocialMediaAccount)
    render(conn, "index.html", user: conn.assigns[:user], social_media_accounts: social_media_accounts)
  end

  def new(conn, _params) do
    changeset = SocialMediaAccount.changeset(%SocialMediaAccount{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"social_media_account" => social_media_account_params}) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:social_media_accounts)
      |> SocialMediaAccount.changeset(social_media_account_params)

    case Repo.insert(changeset) do
      {:ok, _social_media_account} ->
        conn
        |> put_flash(:info, gettext("Social media account created successfully."))
        |> redirect(to: user_social_media_account_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    social_media_account = Repo.get!(SocialMediaAccount, id)
    render(conn, "show.html", social_media_account: social_media_account)
  end

  def edit(conn, %{"id" => id}) do
    social_media_account = Repo.get!(SocialMediaAccount, id)
    changeset = SocialMediaAccount.changeset(social_media_account)
    render(conn, "edit.html", social_media_account: social_media_account, changeset: changeset)
  end

  def update(conn, %{"id" => id, "social_media_account" => social_media_account_params}) do
    social_media_account = Repo.get!(assoc(conn.assigns[:user], :social_media_accounts), id)
    changeset = SocialMediaAccount.changeset(social_media_account, social_media_account_params)

    case Repo.update(changeset) do
      {:ok, social_media_account} ->
        conn
        |> put_flash(:info, gettext("Social media account updated successfully."))
        |> redirect(to: user_social_media_account_path(conn, :show, conn.assigns[:user], social_media_account))
      {:error, changeset} ->
        render(conn, "edit.html", social_media_account: social_media_account, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    social_media_account = Repo.get!(SocialMediaAccount, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(social_media_account)

    conn
    |> put_flash(:info, gettext("Social media account deleted successfully."))
    |> redirect(to: user_social_media_account_path(conn, :index, conn.assigns[:user]))
  end
end

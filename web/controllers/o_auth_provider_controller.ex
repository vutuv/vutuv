defmodule Vutuv.OAuthProviderController do
  use Vutuv.Web, :controller

  alias Vutuv.OAuthProvider

  def index(conn, _params) do
    oauth_providers = Repo.all(OAuthProvider)
    render(conn, "index.html", oauth_providers: oauth_providers)
  end

  def new(conn, _params) do
    changeset = OAuthProvider.changeset(%OAuthProvider{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"o_auth_provider" => o_auth_provider_params}) do
    changeset = OAuthProvider.changeset(%OAuthProvider{}, o_auth_provider_params)

    case Repo.insert(changeset) do
      {:ok, _o_auth_provider} ->
        conn
        |> put_flash(:info, gettext("O auth provider created successfully."))
        |> redirect(to: user_o_auth_provider_path(conn, :index, conn.assigns[:current_user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    o_auth_provider = Repo.get!(OAuthProvider, id)
    render(conn, "show.html", o_auth_provider: o_auth_provider)
  end

  def edit(conn, %{"id" => id}) do
    o_auth_provider = Repo.get!(OAuthProvider, id)
    changeset = OAuthProvider.changeset(o_auth_provider)
    render(conn, "edit.html", o_auth_provider: o_auth_provider, changeset: changeset)
  end

  def update(conn, %{"id" => id, "o_auth_provider" => o_auth_provider_params}) do
    o_auth_provider = Repo.get!(OAuthProvider, id)
    changeset = OAuthProvider.changeset(o_auth_provider, o_auth_provider_params)

    case Repo.update(changeset) do
      {:ok, o_auth_provider} ->
        conn
        |> put_flash(:info, gettext("O auth provider updated successfully."))
        |> redirect(to: user_o_auth_provider_path(conn, :show, o_auth_provider, conn.assigns[:current_user]))
      {:error, changeset} ->
        render(conn, "edit.html", o_auth_provider: o_auth_provider, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    o_auth_provider = Repo.get!(OAuthProvider, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(o_auth_provider)

    conn
    |> put_flash(:info, gettext("O auth provider deleted successfully."))
    |> redirect(to: user_o_auth_provider_path(conn, :index, conn.assigns[:current_user]))
  end
end

defmodule VutuvWeb.ProfileController do
  use VutuvWeb, :controller

  alias Vutuv.Biographies

  def index(conn, _params) do
    profiles = Biographies.list_profiles()
    render(conn, "index.html", profiles: profiles)
  end

  def show(conn, %{"id" => id}) do
    profile = Biographies.get_profile(id)
    render(conn, "show.html", profile: profile)
  end

  def edit(conn, %{"id" => id}) do
    profile = Biographies.get_profile(id)
    changeset = Biographies.change_profile(profile)
    render(conn, "edit.html", profile: profile, changeset: changeset)
  end

  def update(conn, %{"id" => id, "profile" => profile_params}) do
    profile = Biographies.get_profile(id)

    case Biographies.update_profile(profile, profile_params) do
      {:ok, profile} ->
        conn
        |> put_flash(:info, "Profile updated successfully.")
        |> redirect(to: Routes.profile_path(conn, :show, profile))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", profile: profile, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    profile = Biographies.get_profile(id)
    {:ok, _profile} = Biographies.delete_profile(profile)

    conn
    |> put_flash(:info, "Profile deleted successfully.")
    |> redirect(to: Routes.profile_path(conn, :index))
  end
end

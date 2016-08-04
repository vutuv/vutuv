defmodule Vutuv.UserSkillController do
  use Vutuv.Web, :controller
  plug :auth_user

  alias Vutuv.UserSkill

  def index(conn, _params) do
    user =
      Repo.get!(Vutuv.User, conn.assigns[:user].id)
      |> Repo.preload([:user_skills])
    render(conn, "index.html", user_skills: user.user_skills)
  end

  def new(conn, _params) do
    changeset = UserSkill.changeset(%UserSkill{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user_skill" => user_skill_params}) do
    changeset = UserSkill.changeset(%UserSkill{}, user_skill_params)
      |> Ecto.Changeset.put_change(:user_id, conn.assigns[:current_user].id)

    case Repo.insert(changeset) do
      {:ok, _user_skill} ->
        conn
        |> put_flash(:info, gettext("UserSkill created successfully."))
        |> redirect(to: user_user_skill_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_skill = Repo.get!(UserSkill, id)
    render(conn, "show.html", user_skill: user_skill)
  end

  def delete(conn, %{"id" => id}) do
    user_skill = Repo.get!(UserSkill, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user_skill)

    conn
    |> put_flash(:info, gettext("UserSkill deleted successfully."))
    |> redirect(to: user_user_skill_path(conn, :index, conn.assigns[:user]))
  end

  defp auth_user(conn, _opts) do
    if(conn.assigns[:user].id == conn.assigns[:current_user].id) do
      conn
    else
      redirect(conn, to: user_path(conn, :show, conn.assigns[:current_user]))
      |> halt
    end
  end
end

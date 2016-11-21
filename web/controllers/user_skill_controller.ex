defmodule Vutuv.UserSkillController do
  use Vutuv.Web, :controller
  alias Vutuv.UserSkill
  alias Vutuv.Skill

  plug Vutuv.Plug.AuthUser when not action in [:index, :show]

  def index(conn, _params) do
    user =
      Repo.get!(Vutuv.User, conn.assigns[:user].id)
      |> Repo.preload([user_skills: [:endorsements]])
    user_skills = 
      user.user_skills
      |> Enum.sort(&(Enum.count(&1.endorsements)>Enum.count(&2.endorsements)))
    render(conn, "index.html", user_skills: user_skills)
  end

  def new(conn, _params) do
    render(conn, "new.html", conn: conn)
  end

  def create(conn, %{"skill_param" => skill_param}) do
    changeset = 
      case Repo.one(from s in Skill, where: s.name == ^skill_param["name"]) do
        nil ->
          skill = Skill.changeset(%Skill{},skill_param)
          UserSkill.changeset(%UserSkill{}, %{user_id: conn.assigns[:current_user].id})
            |> Ecto.Changeset.put_assoc(:skill, skill)
        skill ->
          UserSkill.changeset(%UserSkill{}, %{
            skill_id: skill.id,
            user_id: conn.assigns[:current_user].id})
      end
    case Repo.insert(changeset) do
      {:ok, _user_skill} ->
        conn
        |> put_flash(:info, gettext("Skill added successfully."))
        |> redirect(to: user_user_skill_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_skill = Repo.get!(UserSkill, id)
      |> Repo.preload([:skill, :endorsements])
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
end

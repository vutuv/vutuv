defmodule Vutuv.SkillController do
  use Vutuv.Web, :controller

  alias Vutuv.Skill

  def index(conn, _params) do
    skills = Repo.all(Skill)
    render(conn, "index.html", skills: skills)
  end

  def new(conn, _params) do
    changeset = Skill.changeset(%Skill{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"skill" => skill_params}) do
    changeset = Skill.changeset(%Skill{}, skill_params)

    case Repo.insert(changeset) do
      {:ok, _skill} ->
        conn
        |> put_flash(:info, gettext("Skill created successfully."))
        |> redirect(to: skill_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    skill = Repo.get!(Skill, id)
    render(conn, "show.html", skill: skill)
  end

  def edit(conn, %{"id" => id}) do
    skill = Repo.get!(Skill, id)
    changeset = Skill.changeset(skill)
    render(conn, "edit.html", skill: skill, changeset: changeset)
  end

  def update(conn, %{"id" => id, "skill" => skill_params}) do
    skill = Repo.get!(Skill, id)
    changeset = Skill.changeset(skill, skill_params)

    case Repo.update(changeset) do
      {:ok, skill} ->
        conn
        |> put_flash(:info, gettext("Skill updated successfully."))
        |> redirect(to: skill_path(conn, :show, skill))
      {:error, changeset} ->
        render(conn, "edit.html", skill: skill, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    skill = Repo.get!(Skill, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(skill)

    conn
    |> put_flash(:info, gettext("Skill deleted successfully."))
    |> redirect(to: skill_path(conn, :index))
  end
end

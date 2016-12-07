defmodule Vutuv.Admin.SkillController do
  use Vutuv.Web, :controller
  import Ecto.Query

  plug Vutuv.Plug.AuthAdmin
  plug :resolve_slug when not action in [:index]


  alias Vutuv.Skill
  alias Vutuv.SkillSynonym

  def index(conn, _params) do
    #Admins need to see a list of all skills that do not have synonyms.
    
    query = from(s in Skill, left_join: syn in assoc(s, :skill_synonyms), group_by: s.id, having: count(syn.id) == 0)
    unvalidated_skills_count = 
      from(subquery(query), select: count("*"))
      |> Repo.one
    unvalidated_skills = 
      query
      |> Vutuv.Pages.paginate(conn.params, unvalidated_skills_count)
      |> Repo.all
    render(conn, "index.html", skills: unvalidated_skills, unvalidated_skills_count: unvalidated_skills_count)
  end

  def show(conn, _params) do
    render conn, "show.html", skill: conn.assigns[:skill] |> Repo.preload([:skill_synonyms])
  end

  def edit(conn, _params) do
    changeset = Skill.changeset(conn.assigns[:skill])
    render conn, "edit.html", skill: conn.assigns[:skill], changeset: changeset
  end

  def update(conn, %{"skill" => params}) do
    conn.assigns[:skill]
    |> Repo.preload([:search_terms, :skill_synonyms])
    |> Skill.changeset(params)
    |> Repo.update
    |> case do
      {:ok, skill} ->
        redirect(conn, to: admin_skill_path(conn, :show, skill))
      {:error, changeset} ->
        render conn, "edit.html", skill: conn.assigns[:skill], changeset: changeset
    end
  end

  def delete(conn, params) do
    conn.assigns[:skill]
    |> Repo.delete
    |> case do
      {:ok, _} -> put_flash(conn, :info, Vutuv.Gettext.gettext("Deletion Succeeded"))
      {:error, _} -> put_flash(conn, :error, Vutuv.Gettext.gettext("Deletion Failed"))
    end
    |> redirect(to: admin_skill_path(conn, :index))
  end

  def easy_validate(conn, _params) do
    skill = conn.assigns[:skill]
    skill
    |> build_assoc(:skill_synonyms)
    |> SkillSynonym.changeset(%{value: skill.name})
    |> Repo.insert
    |> case do
      {:ok, _} -> put_flash(conn, :info, Vutuv.Gettext.gettext("Validation Succeeded"))
      {:error, _} -> put_flash(conn, :error, Vutuv.Gettext.gettext("Validation Failed"))
    end
    |> redirect(to: admin_skill_path(conn, :show, skill))
  end

  def to_synonym(conn, %{"skill" => %{"name" => name}}) do
    Repo.one(from s in Skill, where: s.downcase_name == ^String.downcase(name))
    |> case do
      nil ->
        conn
        |> put_flash(:error, Vutuv.Gettext.gettext("Skill does not exist"))
        |> redirect(to: admin_skill_path(conn, :show, conn.assigns[:skill]))
      skill ->
        SkillSynonym.create_from_skill(conn.assigns[:skill], skill)
        |> case do
          {:ok, new_skill} ->
            conn
            |> put_flash(:info, Vutuv.Gettext.gettext("Succeeded in conversion to synonym"))
            |> redirect(to: admin_skill_path(conn, :show, skill))
          {:error, changeset} ->
            conn
            |> put_flash(:error, Vutuv.Gettext.gettext("Conversion to synonym failed"))
            |> redirect(to: admin_skill_path(conn, :show, skill))
        end
    end
  end

  def add_synonym(conn, %{"synonym" => %{"value" => name}}) do
    skill = conn.assigns[:skill]
    skill
    |> SkillSynonym.create_synonym(name)
    |> case do
      {:ok, _} -> put_flash(conn, :info, Vutuv.Gettext.gettext("Synonym Added Successfully"))
      {:error, _} -> put_flash(conn, :error, Vutuv.Gettext.gettext("Synonym Added Unsuccessfully. This usually means it already exists."))
    end
    |> redirect(to: admin_skill_path(conn, :show, skill))
  end

  def delete_synonym(conn, %{"id" => id}) do
    Repo.get!(SkillSynonym, id)
    |> Repo.delete
    |> case do
      {:ok, _} -> put_flash(conn, :info, Vutuv.Gettext.gettext("Deletion Succeeded"))
      {:error, _} -> put_flash(conn, :error, Vutuv.Gettext.gettext("Deletion Failed"))
    end
    |> redirect(to: admin_skill_path(conn, :show, conn.assigns[:skill]))
  end

  defp resolve_slug(%{params: %{"slug" => slug}} = conn, _params) do
    Repo.one(from s in Skill, where: s.slug == ^slug)
    |> case do
      nil ->
        conn
        |> put_status(404)
        |> render(Vutuv.ErrorView, "404.html")
      skill ->
        assign(conn, :skill, skill)
    end
  end

  defp resolve_slug(conn, _params) do
    conn
    |> put_status(404)
    |> render(Vutuv.ErrorView, "404.html")
  end
end

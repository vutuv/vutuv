defmodule Vutuv.UserSkillController do
  use Vutuv.Web, :controller
  alias Vutuv.UserSkill
  alias Vutuv.Skill

  plug Vutuv.Plug.AuthUser when not action in [:index, :show]
  plug :resolve_slug

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
    conn.assigns[:current_user]
    |> Ecto.build_assoc(:user_skills, %{})
    |> UserSkill.changeset
    |> Skill.create_or_link_skill(skill_param)
    |> Repo.insert
    |> case do
      {:ok, _user_skill} ->
        conn
        |> put_flash(:info, gettext("Skill added successfully."))
        |> redirect(to: user_user_skill_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, params) do
    user_skill = conn.assigns[:user_skill]
      |> Repo.preload([:skill, :endorsements])
    render(conn, "show.html", user_skill: user_skill, work_string_length: 45)
  end

  def delete(conn, params) do
    user_skill = conn.assigns[:user_skill]

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user_skill)

    conn
    |> put_flash(:info, gettext("UserSkill deleted successfully."))
    |> redirect(to: user_user_skill_path(conn, :index, conn.assigns[:user]))
  end

  defp resolve_slug(%{params: %{"id" => slug}} = conn, _) do
    Repo.one(from w in assoc(conn.assigns[:user], :user_skills), join: s in assoc(w, :skill), where: s.slug == ^slug)
    |>case do
      nil -> 
        conn
        |> put_status(404)
        |> render(Vutuv.ErrorView, "404.html")
      user_skill -> assign(conn, :user_skill, user_skill)
    end
    
  end

  defp resolve_slug(conn, _), do: conn
end

defmodule Vutuv.SkillController do
  use Vutuv.Web, :controller
  
  alias Vutuv.Skill

  def index(conn, _params) do
    skills_count = Repo.one(from s in Skill, select: count(s.id))
    skills = 
      from(s in Skill)
      |> Vutuv.Pages.paginate(conn.params, skills_count)
      |> Repo.all
    render(conn, "index.html", skills: skills, skills_count: skills_count)
  end

  def show(conn, %{"slug" => slug}) do
    skill = Repo.one(from s in Skill, where: s.slug == ^slug)
    render conn, "show.html", skill: skill, work_string_length: 45
  end
end

defmodule Vutuv.SkillController do
  use Vutuv.Web, :controller

  plug Vutuv.Plug.All404

  alias Vutuv.Skill

  def index(conn, _params) do
    skills = Repo.all(Skill)
    render(conn, "index.html", skills: skills)
  end

  def show(conn, %{"slug" => slug}) do
    skill = Repo.one(from s in Skill, where: s.downcase_name == ^slug)
    render conn, "show.html", skill: skill
  end
end

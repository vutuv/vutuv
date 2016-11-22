defmodule Vutuv.SkillController do
  use Vutuv.Web, :controller

  plug Vutuv.Plug.All404

  alias Vutuv.Skill

  def index(conn, _params) do
    skills = Repo.all(Skill)
    render(conn, "index.html", skills: skills)
  end

  def show(conn, %{"slug" => slug}) do
    case Repo.one(from s in Skill, where: s.downcase_name == ^slug) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(Vutuv.ErrorView, "404.html")
      skill -> 
      top_users = 
        Repo.all(from s in Vutuv.UserSkill, where: s.skill_id == ^skill.id, limit: 10, preload: [:user, :endorsements])
        |> Enum.sort(fn f1, f2 ->
          Enum.count(f1.endorsements) > Enum.count(f2.endorsements)
        end)
      user = conn.assigns[:current_user]
      top_related =
        if(user) do
          Repo.all(
            from s in Vutuv.UserSkill,
            join: u in assoc(s, :user),
            join: f in assoc(u, :followers),
            where: s.skill_id == ^skill.id and f.id == ^user.id,
            limit: 10,
            preload: [:endorsements, user: [:followers, :followees]])
          |> Enum.sort(fn f1, f2 ->
            Enum.count(f1.endorsements) > Enum.count(f2.endorsements)
          end)
        else
          []
        end
      render conn, "show.html", skill: skill, top_users: top_users, top_related: top_related
    end
  end
end

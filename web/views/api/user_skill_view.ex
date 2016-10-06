defmodule Vutuv.Api.UserSkillView do
  use Vutuv.Web, :view
  import Vutuv.Api.ApiHelpers

  def render("index.json", %{user_skills: user_skills}) do
    %{data: render_many(user_skills, Vutuv.Api.UserSkillView, "user_skill.json")}
  end

  def render("show.json", %{user_skill: user_skill}) do
    %{data: render_one(user_skill, Vutuv.Api.UserSkillView, "user_skill.json")}
  end

  def render("user_skill.json", %{user_skill: user_skill}) do
    %{id: user_skill.id, type: "user_skill"}
    |> put_relationship(:skill, Vutuv.Api.SkillView, "show_lite.json", user_skill)
  end
end

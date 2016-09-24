defmodule Vutuv.Api.SkillView do
  use Vutuv.Web, :view
  import Vutuv.Api.ApiHelpers

  @attributes ~w(name description)a

  def render("index.json", %{skills: skills}) do
    %{data: render_many(skills, Vutuv.Api.SkillView, "skill.json")}
  end

  def render("index_lite.json", %{skills: skills}) do
    %{data: render_many(skills, Vutuv.Api.SkillView, "skill_lite.json")}
  end

  def render("show.json", %{skill: skill}) do
    %{data: render_one(skill, Vutuv.Api.SkillView, "skill.json")}
  end

  def render("show_lite.json", %{skill: skill}) do
    %{data: render_one(skill, Vutuv.Api.SkillView, "skill_lite.json")}
  end

  def render("skill.json", %{skill: skill} = params) do
    render("skill_lite.json", params)
    |> Map.put(:attributes, to_attributes(skill, @attributes))
  end

  def render("skill_lite.json", %{skill: skill}) do
    %{id: skill.id, type: "skill"}
  end
end

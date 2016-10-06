defmodule Vutuv.Api.WorkExperienceView do
  use Vutuv.Web, :view
  import Vutuv.Api.ApiHelpers

  @attributes ~w(
    organization title description start_month
    start_year end_month end_year
  )a

  def render("index.json", %{work_experiences: work_experiences}) do
    %{data: render_many(work_experiences, Vutuv.Api.WorkExperienceView, "work_experience.json")}
  end

  def render("index_lite.json", %{work_experiences: work_experiences}) do
    %{data: render_many(work_experiences, Vutuv.Api.WorkExperienceView, "work_experience_lite.json")}
  end

  def render("show.json", %{work_experience: work_experience}) do
    %{data: render_one(work_experience, Vutuv.Api.WorkExperienceView, "work_experience.json")}
  end

  def render("show_lite.json", %{work_experience: work_experience}) do
    %{data: render_one(work_experience, Vutuv.Api.WorkExperienceView, "work_experience_lite.json")}
  end

  def render("work_experience.json", %{work_experience: work_experience} = params) do
    render("work_experience_lite.json", params)
    |> put_attributes(work_experience, @attributes)
  end

  def render("work_experience_lite.json", %{work_experience: work_experience}) do
    %{id: work_experience.id, type: "work_experience"}
  end
end

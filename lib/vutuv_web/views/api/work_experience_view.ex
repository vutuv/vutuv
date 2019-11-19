defmodule VutuvWeb.Api.WorkExperienceView do
  use VutuvWeb, :view
  alias VutuvWeb.Api.WorkExperienceView

  def render("index.json", %{work_experiences: work_experiences}) do
    %{data: render_many(work_experiences, WorkExperienceView, "work_experience.json")}
  end

  def render("show.json", %{work_experience: work_experience}) do
    %{data: render_one(work_experience, WorkExperienceView, "work_experience.json")}
  end

  def render("work_experience.json", %{work_experience: work_experience}) do
    %{
      id: work_experience.id,
      description: work_experience.description,
      end_date: work_experience.end_date,
      organization: work_experience.organization,
      slug: work_experience.slug,
      start_date: work_experience.start_date,
      title: work_experience.title,
      user_id: work_experience.user_id
    }
  end
end

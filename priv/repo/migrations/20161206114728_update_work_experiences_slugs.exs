defmodule Vutuv.Repo.Migrations.UpdateWorkExperiencesSlugs do
  use Ecto.Migration

  def change do
  	jobs = Vutuv.Repo.all(Vutuv.WorkExperience)
  	for job <- jobs do
  		slug = Vutuv.SlugHelpers.gen_slug_unique(job, :slug)
  		Vutuv.WorkExperience.changeset(job, %{slug: slug})
  		|> Vutuv.Repo.update
  	end
  end
end

defmodule Vutuv.Repo.Migrations.UpdateSkillSlugs do
  use Ecto.Migration

  def change do
  	create unique_index(:skills, [:slug], unique: true)
  	skills = Vutuv.Repo.all(Vutuv.Skill)
  	for skill <- skills do
  		slug = Vutuv.SlugHelpers.gen_slug_unique(skill, :slug)
  		Vutuv.Skill.changeset(skill, %{slug: slug})
  		|> Vutuv.Repo.update
  	end
  end
end

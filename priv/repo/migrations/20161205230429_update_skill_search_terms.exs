defmodule Vutuv.Repo.Migrations.UpdateSkillSearchTerms do
  use Ecto.Migration
  import Ecto.Query

  def change do
		skills = Vutuv.Repo.all(from s in Vutuv.Skill, preload: [:skill_synonyms, :search_terms])
  	for skill <- skills do
  		terms = Vutuv.SearchTerm.skill_search_terms(skill)
  		skill
  		|> Vutuv.Skill.changeset
  		|> Ecto.Changeset.put_assoc(:search_terms, terms)
  		|> Vutuv.Repo.update
  	end
  end
end

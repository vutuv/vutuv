defmodule Vutuv.Repo.Migrations.MigrateSkillsToTags do
  use Ecto.Migration
  alias Ecto.Multi
  import Ecto.Query
  alias Vutuv.Repo

  def change do
		Repo.delete_all(from(e in Vutuv.Endorsement, where:  is_nil(e.user_id) or is_nil(e.user_skill_id)))
		Repo.delete_all(from(e in Vutuv.UserSkill, where: is_nil(e.user_id) or is_nil(e.skill_id)))
		Repo.delete_all(from(t in Vutuv.Tag, where: t.id > 0))
  	skills = Repo.all(from s in Vutuv.Skill, preload: [user_skills: [:user, endorsements: [:user]]])
  	multi = Multi.new
  	for(skill <- skills) do
  		params = %{"value" => truncate_value(skill.downcase_name)}
  		user_tags = 
		  	for(user_skill <- skill.user_skills) do
		  		endorsements = 
			  		for(endorsement <- user_skill.endorsements) do
			  			Ecto.build_assoc(endorsement.user, :endorsements)
			  			|> Vutuv.UserTagEndorsement.changeset()
			  		end
		  		Ecto.build_assoc(user_skill.user, :user_tags)
					|> Vutuv.UserTag.changeset()
					|> Ecto.Changeset.put_assoc(:endorsements, endorsements)
		  	end 
  		Vutuv.Tag.changeset(%Vutuv.Tag{}, params, get_locale(skill))
  		|> Ecto.Changeset.put_assoc(:user_tags, user_tags)
  		|> Repo.insert()
  	end
  end

  def down do
  	
  end

  defp truncate_value(value) do
  	if(String.length(value)>40) do
  		"#{String.slice(value, 0..36)}..."
  	else
  		value
  	end
  end

  defp get_locale(%{user_skills: [user_skill | _] }) do
  	user_skill.user.locale || "en"
  end

  defp get_locale(_), do: "en"
end

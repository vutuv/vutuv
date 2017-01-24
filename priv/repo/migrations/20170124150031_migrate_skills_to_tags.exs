defmodule Vutuv.Repo.Migrations.MigrateSkillsToTags do
  use Ecto.Migration
  alias Ecto.Multi
  import Ecto.Query
  alias Vutuv.Repo

  def change do
  	skills = Repo.all(from s in Vutuv.Skill, preload: [user_skills: [:user, endorsements: [:user]]])
  	multi =
  		Multi.new
  		|> Multi.delete_all(:delete_tags, from(t in Vutuv.Tag, where: t.id > 0))
  	Enum.reduce(skills, multi, fn (skill, acc) ->
  		params = %{"value" => skill.downcase_name}
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
		  changeset = 
	  		Vutuv.Tag.changeset(%Vutuv.Tag{}, params, get_locale(skill))
	  		|> Ecto.Changeset.put_assoc(:user_tags, user_tags)
  		Multi.insert(acc, skill.downcase_name, changeset)
  	end)
  	|> Repo.transaction
  	|> IO.inspect
  end

  def down do
  	
  end

  defp get_locale(%{user_skills: [user_skill | _] }) do
  	user_skill.user.locale || "en"
  end

  defp get_locale(_), do: "en"
end

defmodule Vutuv.Repo.Migrations.ModifyUserSkillsOnDelete do
  use Ecto.Migration

  def change do
  	execute "ALTER TABLE endorsements DROP FOREIGN KEY endorsements_user_skill_id_fkey"
		alter table(:endorsements) do
		  modify :user_skill_id, references(:user_skills, on_delete: :delete_all)
		end
  end
end

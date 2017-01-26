defmodule Vutuv.Repo.Migrations.UpdateTagOnDelete do
  use Ecto.Migration

  def change do
  	execute "ALTER TABLE user_tag_endorsements DROP FOREIGN KEY user_tag_endorsements_user_tag_id_fkey"
  	execute "ALTER TABLE user_tags DROP FOREIGN KEY user_tags_tag_id_fkey"
  	execute "ALTER TABLE tag_closures DROP FOREIGN KEY tag_closures_child_id_fkey"
  	execute "ALTER TABLE tag_closures DROP FOREIGN KEY tag_closures_parent_id_fkey"
		alter table(:user_tag_endorsements) do
		  modify :user_tag_id, references(:user_tags, on_delete: :delete_all)
		end
		alter table(:user_tags) do
		  modify :tag_id, references(:tags, on_delete: :delete_all)
		end
		alter table(:tag_closures) do
		  modify :child_id, references(:tags, on_delete: :delete_all)
		  modify :parent_id, references(:tags, on_delete: :delete_all)
		end
  end

  def down do
  	execute "ALTER TABLE user_tag_endorsements DROP FOREIGN KEY user_tag_endorsements_user_tag_id_fkey"
  	execute "ALTER TABLE user_tags DROP FOREIGN KEY user_tags_tag_id_fkey"
  	execute "ALTER TABLE tag_closures DROP FOREIGN KEY tag_closures_child_id_fkey"
  	execute "ALTER TABLE tag_closures DROP FOREIGN KEY tag_closures_parent_id_fkey"

  	alter table(:user_tag_endorsements) do
		  modify :user_tag_id, references(:user_tags)
		end
		alter table(:user_tags) do
		  modify :tag_id, references(:tags)
		end
		alter table(:tag_closures) do
		  modify :child_id, references(:tags)
		  modify :parent_id, references(:tags)
		end
  end
end

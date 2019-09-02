defmodule Vutuv.Repo.Migrations.CreateUserTagEndorsement do
  use Ecto.Migration

  def change do
    create table(:user_tag_endorsements) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :user_tag_id, references(:user_tags, on_delete: :delete_all)
    end

    create unique_index(:user_tag_endorsements, [:user_id, :user_tag_id],
             name: :user_id_user_tag_id
           )
  end
end

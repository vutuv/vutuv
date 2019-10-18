defmodule Vutuv.Repo.Migrations.CreateUserTags do
  use Ecto.Migration

  def change do
    create table(:user_tags) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:user_tags, [:user_id, :tag_id], name: :user_id_tag_id)
  end
end

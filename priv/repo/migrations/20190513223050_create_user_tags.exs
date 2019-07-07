defmodule Vutuv.Repo.Migrations.CreateUserTags do
  use Ecto.Migration

  def change do
    create table(:user_tags) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :tag_id, references(:tags, on_delete: :delete_all), primary_key: true

      timestamps()
    end

    create index(:user_tags, [:user_id])
    create index(:user_tags, [:tag_id])

    create(unique_index(:user_tags, [:user_id, :tag_id], name: :user_id_tag_id_unique_index))
  end
end

defmodule Vutuv.Repo.Migrations.CreateProfileTags do
  use Ecto.Migration

  def change do
    create table(:profile_tags) do
      add :profile_id, references(:profiles, on_delete: :delete_all), primary_key: true
      add :tag_id, references(:tags, on_delete: :delete_all), primary_key: true

      timestamps()
    end

    create index(:profile_tags, [:profile_id])
    create index(:profile_tags, [:tag_id])

    create(
      unique_index(:profile_tags, [:profile_id, :tag_id], name: :profile_id_tag_id_unique_index)
    )
  end
end

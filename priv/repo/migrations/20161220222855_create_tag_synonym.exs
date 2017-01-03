defmodule Vutuv.Repo.Migrations.CreateTagSynonym do
  use Ecto.Migration

  def change do
    create table(:tag_synonyms) do
      add :tag_id, references(:tags)
      add :locale_id, references(:locales)
      add :value, :string

      timestamps()
    end
    create unique_index(:tag_synonyms, [:value], unique: true)
    create unique_index(:tag_synonyms, [:tag_id, :locale_id], unique: true)
  end
end

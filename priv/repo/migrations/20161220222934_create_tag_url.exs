defmodule Vutuv.Repo.Migrations.CreateTagUrl do
  use Ecto.Migration

  def change do
    create table(:tag_urls) do
      add :tag_localization_id, references(:tag_localizations)
      add :value, :string
      add :name, :string
      add :description, :string

      timestamps()
    end

  end
end

defmodule Vutuv.Repo.Migrations.CreateTagLocalization do
  use Ecto.Migration

  def change do
    create table(:tag_localizations) do
      add :tag_id, references(:tags)
      add :locale_id, references(:locales)
      add :name, :string
      add :description, :string

      timestamps()
    end

  end
end

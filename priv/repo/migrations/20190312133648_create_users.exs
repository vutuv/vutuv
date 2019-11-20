defmodule Vutuv.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :slug, :string
      add :full_name, :string
      add :preferred_name, :string
      add :honorific_prefix, :string
      add :honorific_suffix, :string
      add :gender, :string
      add :birthday, :date
      add :locale, :string, default: "en", null: false
      add :accept_language, :string
      add :avatar, :string
      add :headline, :string
      add :noindex, :boolean, default: false, null: false
      add :subscribe_emails, :boolean, default: false, null: true

      timestamps()
    end

    create unique_index(:users, [:slug])
  end
end

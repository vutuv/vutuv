defmodule Vutuv.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :full_name, :string
      add :preferred_name, :string
      add :honorific_prefix, :string
      add :honorific_suffix, :string
      add :gender, :string
      add :birthday, :date
      add :locale, :string
      add :avatar, :string
      add :active_slug, :string
      add :headline, :string
      add :noindex?, :boolean, default: false, null: false

      timestamps()
    end

    create index(:profiles, [:user_id])
  end
end

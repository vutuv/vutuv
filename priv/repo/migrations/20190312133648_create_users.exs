defmodule Vutuv.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :slug, :string
      add :password_hash, :string
      add :confirmed, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:users, [:slug])
  end
end

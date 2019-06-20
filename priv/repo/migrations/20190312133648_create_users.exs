defmodule Vutuv.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :password_hash, :string
      add :confirmed, :boolean, default: false, null: false

      timestamps()
    end
  end
end

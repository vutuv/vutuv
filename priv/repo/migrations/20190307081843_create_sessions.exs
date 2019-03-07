defmodule Vutuv.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :expires_at, :utc_datetime

      timestamps()
    end
  end
end

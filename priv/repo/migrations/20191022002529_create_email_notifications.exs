defmodule Vutuv.Repo.Migrations.CreateEmailNotifications do
  use Ecto.Migration

  def change do
    create table(:email_notifications) do
      add :subject, :string
      add :body, :string
      add :delivered, :boolean, default: false, null: false
      add :owner_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:email_notifications, [:owner_id])
  end
end

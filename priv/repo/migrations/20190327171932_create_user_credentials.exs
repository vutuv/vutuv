defmodule Vutuv.Repo.Migrations.CreateUserCredentials do
  use Ecto.Migration

  def change do
    create table(:user_credentials) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :password_hash, :string
      add :otp_secret, :string
      add :confirmed, :boolean, default: false, null: false
      add :is_admin, :boolean, default: false, null: false

      timestamps()
    end

    create index(:user_credentials, [:user_id])
  end
end

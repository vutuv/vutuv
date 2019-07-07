defmodule Vutuv.Repo.Migrations.CreateUserCredentials do
  use Ecto.Migration

  def change do
    create table(:user_credentials) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :password_hash, :string
      add :otp_secret, :string
      add :confirmed, :boolean, default: false, null: false
      add :full_name, :string
      add :preferred_name, :string
      add :honorific_prefix, :string
      add :honorific_suffix, :string
      add :gender, :string
      add :birthday, :date
      add :locale, :string
      add :accept_language, :string
      add :avatar, :string
      add :headline, :string
      add :noindex?, :boolean, default: false, null: false

      timestamps()
    end

    create index(:user_credentials, [:user_id])
  end
end

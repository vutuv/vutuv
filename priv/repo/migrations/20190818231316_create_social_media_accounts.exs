defmodule Vutuv.Repo.Migrations.CreateSocialMediaAccounts do
  use Ecto.Migration

  def change do
    create table(:social_media_accounts) do
      add :provider, :string
      add :value, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:social_media_accounts, [:provider, :value], name: :provider_value)
    create index(:social_media_accounts, [:user_id])
  end
end

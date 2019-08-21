defmodule Vutuv.Repo.Migrations.CreateSocialMediaAccounts do
  use Ecto.Migration

  def change do
    create table(:social_media_accounts) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :provider, :string
      add :value, :string

      timestamps()
    end

    create unique_index(:social_media_accounts, [:provider, :value], name: :provider_value)
    create index(:social_media_accounts, [:user_id])
  end
end

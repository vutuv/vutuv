defmodule Vutuv.Repo.Migrations.CreateEmailAddresses do
  use Ecto.Migration

  def change do
    create table(:email_addresses) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :value, :string
      add :description, :string
      add :is_public, :boolean, default: true, null: false
      add :position, :integer
      add :verified, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:email_addresses, [:user_id])

  end
end

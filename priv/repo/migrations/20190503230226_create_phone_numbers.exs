defmodule Vutuv.Repo.Migrations.CreatePhoneNumbers do
  use Ecto.Migration

  def change do
    create table(:phone_numbers) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :value, :string
      add :type, :string

      timestamps()
    end
  end
end

defmodule Vutuv.Repo.Migrations.CreatePhoneNumbers do
  use Ecto.Migration

  def change do
    create table(:phone_numbers) do
      add :value, :string
      add :type, :string
      add :profile_id, references(:profiles, on_delete: :delete_all)

      timestamps()
    end
  end
end

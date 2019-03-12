defmodule Vutuv.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :group_name, :string, default: "regular user"
      add :description, :string

      timestamps()
    end

  end
end

defmodule Vutuv.Repo.Migrations.CreateWorkExperiences do
  use Ecto.Migration

  def change do
    create table(:work_experiences) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :organization, :string
      add :title, :string
      add :description, :string
      add :start_date, :date
      add :end_date, :date
      add :slug, :string

      timestamps()
    end

    create index(:work_experiences, [:user_id])
  end
end

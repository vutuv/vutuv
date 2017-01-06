defmodule Vutuv.Repo.Migrations.CreateTagClosure do
  use Ecto.Migration

  def change do
    create table(:tag_closures) do
      add :parent_id, references(:tags)
      add :child_id, references(:tags)
      add :depth, :integer

      timestamps()
    end

  end
end

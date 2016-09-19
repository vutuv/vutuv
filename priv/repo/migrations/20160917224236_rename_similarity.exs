defmodule Vutuv.Repo.Migrations.RenameSimilarity do
  use Ecto.Migration

  def change do
    alter table(:search_terms) do
      remove :similarity
      add :score, :integer
    end
  end
end

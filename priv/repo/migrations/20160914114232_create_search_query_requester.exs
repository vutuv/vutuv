defmodule Vutuv.Repo.Migrations.CreateSearchQueryRequester do
  use Ecto.Migration

  def change do
    create table(:search_query_requesters) do
      add :user_id, references(:users, on_delete: :nothing)
      add :search_query_id, references(:search_queries, on_delete: :nothing)
      timestamps
    end

  end
end

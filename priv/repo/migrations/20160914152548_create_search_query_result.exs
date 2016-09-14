defmodule Vutuv.Repo.Migrations.CreateSearchQueryResult do
  use Ecto.Migration

  def change do
    create table(:search_query_results) do
    	add :user_id, references(:users, on_delete: :nothing)
    	add :search_query_requester_id, references(:search_query_requesters, on_delete: :nothing)
      timestamps
    end
  end
end

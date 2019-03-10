defmodule Vutuv.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :body, :string
      add :page_info_cache, :string 
      add :visibility_level, :string, default: "private"
      add :published_at, :utc_datetime
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:posts, [:user_id])
  
  end
end

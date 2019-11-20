defmodule Vutuv.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :body, :text
      add :title, :string
      add :page_info_cache, :string
      add :visibility_level, :string, default: "private", null: false
      add :published_at, :utc_datetime

      timestamps()
    end

    create index(:posts, [:user_id, :title])
  end
end

defmodule Vutuv.Repo.Migrations.CreatePostTags do
  use Ecto.Migration

  def change do
    create table(:post_tags, primary_key: false) do
      add :post_id, references(:posts, on_delete: :delete_all), primary_key: true
      add :tag_id, references(:tags, on_delete: :delete_all), primary_key: true
    end

    create index(:post_tags, [:post_id])
    create index(:post_tags, [:tag_id])

    create unique_index(:post_tags, [:post_id, :tag_id], name: :post_id_tag_id)
  end
end

defmodule Vutuv.Repo.Migrations.CreateUserConnections do
  use Ecto.Migration

  def change do
    create table(:user_connections, primary_key: false) do
      add :followee_id, references(:users, on_delete: :delete_all), primary_key: true
      add :follower_id, references(:users, on_delete: :delete_all), primary_key: true
    end

    create index(:user_connections, [:followee_id])
    create index(:user_connections, [:follower_id])

    create(
      unique_index(:user_connections, [:followee_id, :follower_id], name: :followee_id_follower_id)
    )
  end
end

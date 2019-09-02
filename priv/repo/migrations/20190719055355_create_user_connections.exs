defmodule Vutuv.Repo.Migrations.CreateUserConnections do
  use Ecto.Migration

  def change do
    create table(:user_connections, primary_key: false) do
      add :leader_id, references(:users, on_delete: :delete_all), primary_key: true
      add :follower_id, references(:users, on_delete: :delete_all), primary_key: true
    end

    create index(:user_connections, [:leader_id])
    create index(:user_connections, [:follower_id])

    create(
      unique_index(:user_connections, [:leader_id, :follower_id], name: :leader_id_follower_id)
    )
  end
end

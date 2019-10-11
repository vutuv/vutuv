defmodule Vutuv.Repo.Migrations.CreateUserConnections do
  use Ecto.Migration

  def change do
    create table(:user_connections) do
      add :followee_id, references(:users, on_delete: :delete_all)
      add :follower_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create(
      unique_index(:user_connections, [:followee_id, :follower_id], name: :followee_id_follower_id)
    )
  end
end

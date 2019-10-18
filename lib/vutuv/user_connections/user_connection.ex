defmodule Vutuv.UserConnections.UserConnection do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.UserProfiles.User

  @type t :: %__MODULE__{
          id: integer,
          followee: User.t() | %Ecto.Association.NotLoaded{},
          follower: User.t() | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "user_connections" do
    belongs_to :followee, User
    belongs_to :follower, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_connection, attrs) do
    user_connection
    |> cast(attrs, [:followee_id, :follower_id])
    |> validate_required([:followee_id, :follower_id])
    |> validate_not_following_self()
    |> unique_constraint(:followee_id, name: :followee_id_follower_id)
  end

  defp validate_not_following_self(
         %{changes: %{followee_id: same, follower_id: same}} = changeset
       ) do
    add_error(changeset, :follower_id, "cannot follow yourself")
  end

  defp validate_not_following_self(changeset), do: changeset
end

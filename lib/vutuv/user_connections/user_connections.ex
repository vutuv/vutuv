defmodule Vutuv.UserConnections.UserConnection do
  use Ecto.Schema

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
end

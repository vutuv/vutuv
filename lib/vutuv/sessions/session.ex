defmodule Vutuv.Sessions.Session do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.UserProfiles.User

  @max_age 86_400

  @type t :: %__MODULE__{
          id: integer,
          expires_at: DateTime.t(),
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "sessions" do
    field :expires_at, :utc_datetime

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = session, attrs) do
    session
    |> set_expires_at(attrs)
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
  end

  defp set_expires_at(%__MODULE__{} = session, attrs) do
    max_age = attrs[:max_age] || @max_age
    expires_at = DateTime.add(DateTime.truncate(DateTime.utc_now(), :second), max_age)
    %__MODULE__{session | expires_at: expires_at}
  end
end

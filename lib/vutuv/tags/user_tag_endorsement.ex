defmodule Vutuv.Tags.UserTagEndorsement do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.Tags.UserTag
  alias Vutuv.UserProfiles.User

  @type t :: %__MODULE__{
          id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
          user_tag: UserTag.t() | %Ecto.Association.NotLoaded{}
        }

  schema "user_tag_endorsements" do
    belongs_to :user, User
    belongs_to :user_tag, UserTag
  end

  @doc false
  def changeset(%__MODULE__{} = user_tag_endorsement, attrs) do
    user_tag_endorsement
    |> cast(attrs, [:user_id, :user_tag_id])
    |> validate_required([:user_id, :user_tag_id])
    |> unique_constraint(:user_id, name: :user_id_user_tag_id)
  end
end

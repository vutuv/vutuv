defmodule Vutuv.Tags.UserTag do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.Accounts.User
  alias Vutuv.Tags.Tag

  @type t :: %__MODULE__{
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
          tag_id: integer,
          tag: Tag.t() | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "user_tags" do
    belongs_to :user, User
    belongs_to :tag, Tag

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = user_tag, attrs) do
    user_tag
    |> cast(attrs, [:user_id, :tag_id])
    |> validate_required([:user_id, :tag_id])
    |> foreign_key_constraint(:tag_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_tag,
      name: :user_id_tag_id_unique_index
    )
  end
end

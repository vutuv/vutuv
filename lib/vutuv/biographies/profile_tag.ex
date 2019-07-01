defmodule Vutuv.Biographies.ProfileTag do
  use Ecto.Schema
  import Ecto.Changeset

  alias Vutuv.Biographies.Profile
  alias Vutuv.Generals.Tag

  @type t :: %__MODULE__{
          profile_id: integer,
          profile: Profile.t() | %Ecto.Association.NotLoaded{},
          tag_id: integer,
          tag: Tag.t() | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "profile_tags" do
    belongs_to :profile, Profile
    belongs_to :tag, Tag

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = profile_tag, attrs) do
    profile_tag
    |> cast(attrs, [:profile_id, :tag_id])
    |> validate_required([:profile_id, :tag_id])
    |> foreign_key_constraint(:tag_id)
    |> foreign_key_constraint(:profile_id)
    |> unique_constraint(:profile_tag,
      name: :profile_id_tag_id_unique_index
    )
  end
end

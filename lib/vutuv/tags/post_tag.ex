defmodule Vutuv.Tags.PostTag do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.Tags.Tag
  alias Vutuv.Publications.Post

  @type t :: %__MODULE__{
          id: integer,
          post: Post.t() | %Ecto.Association.NotLoaded{},
          tag: Tag.t() | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "post_tags" do
    belongs_to :post, Post
    belongs_to :tag, Tag

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:tag_id])
    |> validate_required(:tag_id)
    |> unique_constraint(:tag_id, name: :post_id_tag_id)
  end
end

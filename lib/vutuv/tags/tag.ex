defmodule Vutuv.Tags.Tag do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.Tags.{PostTag, UserTag}

  @type t :: %__MODULE__{
          id: integer,
          name: String.t(),
          downcase_name: String.t(),
          description: String.t(),
          slug: String.t(),
          url: String.t(),
          post_tags: [PostTag.t()] | %Ecto.Association.NotLoaded{},
          user_tags: [UserTag.t()] | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "tags" do
    field :name, :string
    field :downcase_name, :string
    field :description, :string
    field :slug, :string
    field :url, :string

    has_many :post_tags, PostTag, on_delete: :delete_all
    has_many :user_tags, UserTag, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = tag, attrs) do
    tag
    |> cast(attrs, [:name, :downcase_name, :slug, :description, :url])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)
    |> unique_constraint(:downcase_name)
    |> unique_constraint(:slug)
  end
end

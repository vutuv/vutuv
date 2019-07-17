defmodule Vutuv.Tags.Tag do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.{Accounts.User, Socials.Post}

  @type t :: %__MODULE__{
          id: integer,
          name: String.t(),
          downcase_name: String.t(),
          description: String.t(),
          slug: String.t(),
          url: String.t(),
          posts: [Post.t()] | %Ecto.Association.NotLoaded{},
          users: [User.t()] | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "tags" do
    field :name, :string
    field :downcase_name, :string
    field :description, :string
    field :slug, :string
    field :url, :string

    many_to_many :posts, Post, join_through: "post_tags", on_replace: :delete
    many_to_many :users, User, join_through: "user_tags", on_replace: :delete

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

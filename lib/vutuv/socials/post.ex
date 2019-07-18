defmodule Vutuv.Socials.Post do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.{Accounts.User, Tags.Tag}

  @type t :: %__MODULE__{
          id: integer,
          body: String.t(),
          page_info_cache: String.t(),
          published_at: DateTime.t(),
          title: String.t(),
          visibility_level: String.t(),
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
          tags: [Tag.t()] | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "posts" do
    field :body, :string
    field :page_info_cache, :string
    field :published_at, :utc_datetime
    field :title, :string
    field :visibility_level, :string, default: "private"

    belongs_to :user, User

    many_to_many :tags, Tag, join_through: "post_tags", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = post, attrs) do
    post
    |> cast(attrs, [:body, :title, :page_info_cache, :visibility_level])
    |> validate_required([:body, :title])
    |> validate_length(:body, max: 150_000)
    |> validate_length(:title, max: 255)
    |> unique_constraint(:title)
  end

  @doc false
  def create_changeset(%__MODULE__{} = post, attrs) do
    post |> set_published_at(attrs) |> changeset(attrs)
  end

  defp set_published_at(%__MODULE__{} = post, attrs) do
    published_at = attrs[:published_at] || DateTime.truncate(DateTime.utc_now(), :second)
    %__MODULE__{post | published_at: published_at}
  end

  @doc """
  Changeset for adding and updating post_tags.
  """
  def post_tag_changeset(%__MODULE__{} = post, tags) do
    post
    |> cast(%{}, [:body, :title])
    |> put_assoc(:tags, tags)
  end
end

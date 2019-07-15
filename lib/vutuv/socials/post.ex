defmodule Vutuv.Socials.Post do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.Accounts.User

  @type t :: %__MODULE__{
          id: integer,
          body: String.t(),
          page_info_cache: String.t(),
          published_at: DateTime.t(),
          title: String.t(),
          visibility_level: String.t(),
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
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

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = post, attrs) do
    post
    |> cast(attrs, [:body, :title, :page_info_cache, :visibility_level])
    |> validate_required([:body, :title])
    |> validate_length(:body, max: 255)
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
end

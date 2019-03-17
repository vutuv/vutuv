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
          user: %Ecto.Association.NotLoaded{} | User.t(),
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

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :title, :page_info_cache, :visibility_level, :published_at])
    |> validate_required([:body, :title, :page_info_cache, :visibility_level, :published_at])
  end
end

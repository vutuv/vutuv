defmodule Vutuv.Socials.Post do
  use Ecto.Schema
  import Ecto.Changeset


  schema "posts" do
    field :body, :string
    field :title, :string
    field :page_info_cache, :string 
    field :visibility_level, :string, default: "private"
    field :published_at, :utc_datetime
    belongs_to :user, Vutuv.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end

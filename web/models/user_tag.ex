defmodule Vutuv.UserTag do
  use Vutuv.Web, :model
  import Ecto.Query

  schema "user_tags" do
    belongs_to :user, Vutuv.User
    belongs_to :tag, Vutuv.Tag

    has_many :endorsements, Vutuv.UserTagEndorsement, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :tag_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:tag_id)
    |> unique_constraint(:user_id_tag_id, message: "You already have this tag.")
  end

  def default_name(user_tag) do
    Vutuv.Repo.one(from l in assoc(user_tag.tag, :tag_localizations),
      left_join: loc in assoc(l, :locale),
      select: l.name,
      limit: 1)
  end

  def resolve_name(user_tag, locale) do
    user_tag = 
      user_tag
      |> Vutuv.Repo.preload([tag: :tag_localizations])
    query =   
      from(l in assoc(user_tag.tag, :tag_localizations),
        left_join: loc in assoc(l, :locale),
        where: loc.value == ^locale)
    if(Vutuv.Repo.one(query |> select([l, loc], count("*"))) == 0) do
      default_name(user_tag)
    else
      Vutuv.Repo.one(query |> select([l], l.name))
    end
  end

  def truncated_name(user_tag, locale) do
    tag_name = resolve_name(user_tag, locale)

    truncated_tag_name = tag_name
    |>String.slice(0..50)

    if truncated_tag_name == tag_name do
      tag_name
    else
      truncated_tag_name <> " ..."
    end
  end

  defimpl Phoenix.Param, for: __MODULE__ do
    def to_param(user_tag) do
      Vutuv.Repo.preload(user_tag, [:tag]).tag.slug
    end
  end
end

defmodule Vutuv.UserTag do
  use Vutuv.Web, :model
  import Ecto.Query

  schema "user_tags" do
    belongs_to :user, Vutuv.User
    belongs_to :tag, Vutuv.Tag

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
  end

  def default_name(user_tag) do
    Vutuv.Repo.one(from l in assoc(user_tag.tag, :tag_localizations),
      left_join: loc in assoc(l, :locale),
      where: loc.value == "en",
      select: l.name)
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
end

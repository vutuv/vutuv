defmodule Vutuv.Tag do
  use Vutuv.Web, :model

  schema "tags" do
    field :slug, :string

    has_many :tag_localizations, Vutuv.TagLocalization, on_delete: :delete_all
    has_many :tag_synonyms, Vutuv.TagSynonym, on_delete: :delete_all
    #has_many :user_tags, Vutuv.UserTag, on_delete: :delete_all

    # has_many :parent_closures, Vutuv.TagClosure, foreign_key: :child_id, on_delete: :delete_all
    # has_many :parents, through: [:parent_closures, :parent]

    # has_many :child_closures, Vutuv.TagClosure, foreign_key: :parent_id, on_delete: :delete_all
    # has_many :children, through: [:child_closures, :child]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{})

  def changeset(struct, %{"value" => value} = params) do
    struct
    |> cast(params, [:slug])
    |> gen_slug(value)
    |> default_localization(value)
    |> validate_required([:slug])
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:slug])
    |> validate_required([:slug])
  end

  def gen_slug(changeset, value) do
    changeset
    |> put_change(:slug, Vutuv.SlugHelpers.gen_slug_unique(value, __MODULE__, :slug))
  end

  def default_localization(changeset, value) do
    localization = 
      %Vutuv.TagLocalization{}
      |> Vutuv.TagLocalization.changeset(%{name: value, locale_id: Vutuv.Locale.locale_id("en")})
    changeset
    |> put_assoc(:tag_localizations, [localization])
  end

  def create_or_link_tag(changeset, %{"value" => value} = params) do
    downcase_value = String.downcase(value)
    Vutuv.Repo.one(from t in __MODULE__, 
      left_join: syn in assoc(t, :tag_synonyms),
      left_join: loc in assoc(t, :tag_localizations),
      where: syn.value == ^downcase_value or loc.name == ^downcase_value, limit: 1)
    |> case do
      nil ->
        tag = __MODULE__.changeset(%__MODULE__{}, params)
        put_assoc(changeset, :tag, tag)
      tag ->
        put_change(changeset, :tag_id, tag.id)
    end
  end

  defimpl String.Chars, for: Vutuv.Tag do
    def to_string(tag), do: "#{tag.slug}"
  end

  defimpl List.Chars, for: Vutuv.Tag do
    def to_charlist(tag), do: '#{tag.slug}'
  end
end

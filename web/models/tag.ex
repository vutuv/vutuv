defmodule Vutuv.Tag do
  use Vutuv.Web, :model
  @derive {Phoenix.Param, key: :slug}
  

  schema "tags" do
    field :slug, :string

    has_many :tag_localizations, Vutuv.TagLocalization, on_delete: :delete_all
    has_many :tag_synonyms, Vutuv.TagSynonym, on_delete: :delete_all

    has_many :parent_closures, Vutuv.TagClosure, foreign_key: :child_id, on_delete: :delete_all
    has_many :parents, through: [:parent_closures, :parent]

    has_many :child_closures, Vutuv.TagClosure, foreign_key: :parent_id, on_delete: :delete_all
    has_many :children, through: [:child_closures, :child]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}, locale \\ "en")

  def changeset(struct, %{"value" => value} = params, locale) do
    struct
    |> cast(params, [:slug])
    |> gen_slug(value)
    |> validate_required([:slug])
    |> validate_length(:slug, max: 60)
    |> unique_constraint(:slug)
    |> default_localization(value, locale)
  end

  def changeset(struct, params, locale) do
    struct
    |> cast(params, [:slug])
    |> validate_required([:slug])
    |> validate_length(:slug, max: 60)
    |> unique_constraint(:slug)
    |> default_localization(params["slug"], locale)
  end

  def edit_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:slug])
    |> validate_required([:slug])
    |> unique_constraint(:slug)
    |> validate_length(:slug, max: 60)
  end

  def gen_slug(changeset, value) do
    slug = 
      value
      |> Vutuv.SlugHelpers.gen_slug_unique( __MODULE__, :slug)
      |> String.replace(".", "_")
    put_change(changeset, :slug, slug)
  end

  def default_localization(changeset, value, locale) do
    localization = 
      %Vutuv.TagLocalization{}
      |> Vutuv.TagLocalization.changeset(%{name: value, locale_id: Vutuv.Locale.locale_id(locale)})
    changeset
    |> put_assoc(:tag_localizations, [localization])
  end

  def create_or_link_tag(changeset, %{"value" => value} = params, locale) do
    downcase_value = String.downcase(value)
    Vutuv.Repo.one(from t in __MODULE__, 
      left_join: syn in assoc(t, :tag_synonyms),
      left_join: loc in assoc(t, :tag_localizations),
      where: syn.value == ^downcase_value or loc.name == ^downcase_value, limit: 1)
    |> case do
      nil ->
        tag = __MODULE__.changeset(%__MODULE__{}, params, locale)
        put_assoc(changeset, :tag, tag)
      tag ->
        put_change(changeset, :tag_id, tag.id)
    end
  end

  def resolve_localization(tag, locale) do
    Vutuv.Repo.one(from(t in Vutuv.TagLocalization, 
      where: t.locale_id == ^(Vutuv.Locale.locale_id(locale)) and
      t.tag_id == ^tag.id,
      preload: [:tag_urls]))
    ||
    Vutuv.Repo.one(from(t in Vutuv.TagLocalization, 
      where: t.tag_id == ^tag.id,
      preload: [:tag_urls],
      limit: 1))
  end

  def related_users(_, nil), do: []

  def related_users(tag, current_user) do
    (Vutuv.Repo.all(from u in assoc(current_user, :followers),
      left_join: us in assoc(u, :user_tags),
      left_join: e in assoc(us, :endorsements),
      where: us.tag_id == ^tag.id,
      order_by: fragment("count(?) DESC", e.id), #most endorsed
      group_by: u.id,
      limit: 10)
    ++
    Vutuv.Repo.all(from u in assoc(current_user, :followees),
      left_join: us in assoc(u, :user_tags),
      left_join: e in assoc(us, :endorsements),
      where: us.tag_id == ^tag.id,
      order_by: fragment("count(?) DESC", e.id), #most endorsed
      group_by: u.id,
      limit: 10))
    |> Enum.uniq_by(&(&1.id))
  end

  def reccomended_users(tag) do
    Vutuv.Repo.all(from u in Vutuv.User,
      left_join: us in assoc(u, :user_tags),
      left_join: e in assoc(us, :endorsements),
      where: us.tag_id == ^tag.id,
      order_by: fragment("count(?) DESC", e.id), #most endorsed
      group_by: u.id,
      limit: 10)
  end

  defimpl String.Chars, for: Vutuv.Tag do
    def to_string(tag), do: "#{tag.slug}"
  end

  defimpl List.Chars, for: Vutuv.Tag do
    def to_charlist(tag), do: '#{tag.slug}'
  end
end

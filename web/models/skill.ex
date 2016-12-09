defmodule Vutuv.Skill do
  use Vutuv.Web, :model
  @derive {Phoenix.Param, key: :slug}

  schema "skills" do
    field :name, :string
    field :downcase_name, :string
    field :slug, :string
    field :description, :string
    field :url, :string

    has_many :user_skills, Vutuv.UserSkill, on_delete: :delete_all
    has_many :skill_synonyms, Vutuv.SkillSynonym, on_delete: :delete_all
    has_many :search_terms, Vutuv.SearchTerm, on_delete: :delete_all, on_replace: :delete

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(downcase_name slug description url)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields++@optional_fields)
    |> validate_required([:name])
    |> validate_length(:name, max: 45)
    |> put_downcase_if_name_changed(model)
    |> unique_constraint(:downcase_name)
    |> unique_constraint(:slug)
  end

  defp put_downcase_if_name_changed(changeset, model) do
    #also sets slug and search_terms
    changeset
    |> get_change(:name)
    |> case do
      nil ->
        changeset
      name ->
        term_params = 
          if(model == %__MODULE__{}) do
            %__MODULE__{downcase_name: String.downcase(name), skill_synonyms: []}
          else
            Map.put(model, :downcase_name, String.downcase(name))
          end
        search_terms = Vutuv.SearchTerm.skill_search_terms(term_params)
        changeset
        |> put_change(:slug, Vutuv.SlugHelpers.gen_slug_unique(%__MODULE__{name: name}, :slug))
        |> put_change(:downcase_name, name)
        |> update_change(:downcase_name, &String.downcase/1)
        |> put_assoc(:search_terms, search_terms)
    end
  end

  def create_or_link_skill(changeset, %{"name" => name} = params) do
    downcase_name = String.downcase(name)
    Vutuv.Repo.one(from s in __MODULE__, left_join: syn in assoc(s, :skill_synonyms), where: s.downcase_name == ^downcase_name or syn.value == ^downcase_name, limit: 1)
    |> case do
      nil ->
        skill = __MODULE__.changeset(%__MODULE__{}, params)
        Ecto.Changeset.put_assoc(changeset, :skill, skill)
      skill ->
        Ecto.Changeset.put_change(changeset, :skill_id, skill.id)
    end
  end

  def resolve_name(skill_id) do
    Vutuv.Repo.one!(from s in Vutuv.Skill, where: s.id == ^skill_id, select: [s.name])
  end

  def related_users(_, nil), do: []

  def related_users(skill, current_user) do
    (Vutuv.Repo.all(from u in assoc(current_user, :followers),
      left_join: us in assoc(u, :user_skills),
      left_join: e in assoc(us, :endorsements),
      where: us.skill_id == ^skill.id,
      order_by: fragment("count(?) DESC", e.id), #most endorsed
      group_by: u.id,
      limit: 10)
    ++
    Vutuv.Repo.all(from u in assoc(current_user, :followees),
      left_join: us in assoc(u, :user_skills),
      left_join: e in assoc(us, :endorsements),
      where: us.skill_id == ^skill.id,
      order_by: fragment("count(?) DESC", e.id), #most endorsed
      group_by: u.id,
      limit: 10))
    |> Enum.uniq_by(&(&1.id))
  end

  def reccomended_users(skill) do
    Vutuv.Repo.all(from u in Vutuv.User,
      left_join: us in assoc(u, :user_skills),
      left_join: e in assoc(us, :endorsements),
      where: us.skill_id == ^skill.id,
      order_by: fragment("count(?) DESC", e.id), #most endorsed
      group_by: u.id,
      limit: 10)
  end

  defimpl String.Chars, for: __MODULE__ do
    def to_string(skill), do: "#{skill.name}"
  end

  defimpl List.Chars, for: __MODULE__ do
    def to_charlist(skill), do: '#{skill.name}'
  end
end

defmodule Vutuv.Skill do
  use Vutuv.Web, :model
  @derive {Phoenix.Param, key: :downcase_name}

  schema "skills" do
    field :name, :string
    field :downcase_name, :string
    field :slug, :string
    field :description, :string
    field :url, :string

    has_many :user_skills, Vutuv.UserSkill, on_delete: :delete_all
    has_many :skill_synonyms, Vutuv.SkillSynonym, on_delete: :delete_all

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
    |> put_downcase_if_name_changed
    |> unique_constraint(:downcase_name)
  end

  defp put_downcase_if_name_changed(changeset) do
    changeset
    |> get_change(:name)
    |> case do
      nil ->
        changeset
      name ->
        changeset
        |> put_change(:downcase_name, name)
        |> update_change(:downcase_name, &String.downcase/1)
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
end

defmodule Vutuv.SkillSynonym do
  use Vutuv.Web, :model
  alias Vutuv.Repo
  alias Vutuv.UserSkill
  alias Vutuv.Skill

  schema "skill_synonyms" do
    field :value, :string

    belongs_to :skill, Vutuv.Skill

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value])
    |> validate_required([:value])
    |> update_change(:value, &String.downcase/1)
    |> unique_constraint(:value)
  end

  def create_from_skill(%Skill{name: name} = skill_for_synonym, %Skill{} = skill) do
    create_synonym(skill, name)
    user_skills = Repo.all(from(u in UserSkill, where: u.skill_id == ^skill_for_synonym.id))
    for(user_skill <- user_skills) do
      user_skill
      |> UserSkill.changeset(%{skill_id: skill.id})
      |> Repo.update
    end

    # |> Repo.update_all(set: [skill_id: skill.id])

    Repo.delete(skill_for_synonym)
  end

  def create_synonym(skill, name) do
    skill
    |> build_assoc(:search_terms)
    |> Vutuv.SearchTerm.changeset(%{value: name})
    |> Repo.insert!
    skill
    |> build_assoc(:skill_synonyms)
    |> changeset(%{value: name})
    |> Repo.insert
  end
end

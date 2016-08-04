defmodule Vutuv.Skill do
  use Vutuv.Web, :model

  schema "skills" do
    field :name, :string
    field :downcase_name, :string
    field :slug, :string
    field :description, :string
    field :url, :string

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
    |> put_change(:downcase_name, params["name"])
    |> update_change(:downcase_name, &String.downcase/1)
    |> unique_constraint(:downcase_name)
  end

  def resolve_name(skill_id) do
    Vutuv.Repo.one!(from s in Vutuv.Skill, where: s.id == ^skill_id, select: [s.name])
  end
end

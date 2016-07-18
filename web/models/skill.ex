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
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

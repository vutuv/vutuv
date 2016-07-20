defmodule Vutuv.Competence do
  use Vutuv.Web, :model

  schema "competences" do
    belongs_to :user, Vutuv.User
    belongs_to :skill, Vutuv.Skill

    timestamps
  end

  @required_fields ~w(user_id skill_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:skill_id)
    |> unique_constraint(:user_id_skill_id)
  end
end

defmodule Vutuv.Slug do
  use Vutuv.Web, :model

  schema "slugs" do
    field :value, :string
    belongs_to :user, Vutuv.User
    timestamps
  end

  @required_fields ~w(value)
  @optional_fields ~w(id user_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_format(:value, ~r/^\D{1}\S+$/u)
    |> unique_constraint(:value)
  end
end

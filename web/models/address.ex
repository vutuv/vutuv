defmodule Vutuv.Address do
  use Vutuv.Web, :model

  schema "addresses" do
    field :description, :string
    field :line_1, :string
    field :line_2, :string
    field :zip_code, :string
    field :city, :string
    field :state, :string
    field :country, :string

    belongs_to :user, Vutuv.User
    timestamps
  end

  @required_fields ~w(description line_1 zip_code city state country)
  @optional_fields ~w(line_2)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required([:description, :line_1, :zip_code, :city, :state, :country])
    |> validate_format(:zip_code, ~r/^\d{5}(-\d{4})?$/u)
  end
end

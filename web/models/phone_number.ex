defmodule Vutuv.PhoneNumber do
  use Vutuv.Web, :model

  schema "phone_numbers" do
    field :value, :string
    field :number_type, :string

    belongs_to :user, Vutuv.User
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:value, :number_type])
    |> validate_required([:value, :number_type])
    |> validate_format(:value, ~r/^\d*$/u)
  end
end

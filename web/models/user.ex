defmodule Vutuv.User do
  use Vutuv.Web, :model

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :middlename, :string
    field :nickname, :string
    field :honorific_prefix, :string
    field :honorific_suffix, :string
    field :gender, :string
    field :birthdate, Ecto.Date
    field :verified, :boolean, default: false

    timestamps
  end

  @required_fields ~w(first_name last_name middlename nickname honorific_prefix honorific_suffix gender birthdate verified)
  @optional_fields ~w()

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

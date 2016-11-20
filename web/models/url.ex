defmodule Vutuv.Url do
  use Vutuv.Web, :model

  schema "urls" do
    field :value, :string
    field :description, :string

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
    |> cast(params, [:value, :description])
    |> validate_required([:value])
    |> validate_format(:value, ~r/^http(s)?:\/\/([a-z0-9]+\.)?[a-z0-9]+.[a-z]+$/u)
  end
end

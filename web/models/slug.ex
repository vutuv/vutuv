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
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> downcase_value
    |> validate_format(:value, ~r/^[a-z]{1}[a-z0-9-.]*$/u)
    |> unique_constraint(:value)
  end

  def downcase_value(changeset) do
    # If the value has been changed, downcase it.
    update_change(changeset, :value, &String.downcase/1)
  end

end

defmodule Vutuv.SearchTerm do
  use Vutuv.Web, :model

  schema "search_terms" do
    field :value, :string
    field :score, :integer

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
    |> cast(params, [:value, :score])
    |>downcase_value
  end

  defp downcase_value(changeset) do
    # If the value has been changed, downcase it.
    update_change(changeset, :value, &String.downcase/1)
  end
end

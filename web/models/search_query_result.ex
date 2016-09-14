defmodule Vutuv.SearchQueryResult do
  use Vutuv.Web, :model

  schema "search_query_results" do
    belongs_to :user, Vutuv.User
    belongs_to :search_query_requester, Vutuv.SearchQueryRequester
    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

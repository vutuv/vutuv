defmodule Vutuv.SearchQueryRequester do
  use Vutuv.Web, :model

  schema "search_query_requesters" do
    belongs_to :user, Vutuv.User
    belongs_to :search_query, Vutuv.SearchQuery
    timestamps()
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:search_query_id, :user_id])
  end
end

defmodule Vutuv.SearchQueryController do
  use Vutuv.Web, :controller
  import Vutuv.UserHelpers
  alias Vutuv.SearchQuery

  def index(conn, _params) do
    changeset = SearchQuery.changeset(%SearchQuery{})
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, %{"search_query" => search_query_params}) do
    id = if conn.assigns[:current_user], do: conn.assigns[:current_user].id, else: nil
    results = users_by_email search_query_params["value"]
    results_assocs = 
      for(user <- results) do
        Ecto.build_assoc(user, :search_query_results)
      end
    Repo.one(from q in Vutuv.SearchQuery, where: q.value == ^search_query_params["value"], select: q.id)
    |>requester_changeset(id, results, search_query_params, results_assocs)
    |>Repo.insert
    |>case do
      {:ok, _} ->
        conn
        |> put_flash(:info, gettext("Search query executed successfully."))
        |> render("index.html", changeset: SearchQuery.changeset(%SearchQuery{}, %{value: search_query_params["value"]}), results: results)
      {:error, changeset} ->
        render(conn, "index.html", changeset: changeset)
    end
  end

  def requester_changeset(id, requester_id, results, search_query_params, results_assocs) do
    changeset =
      Vutuv.SearchQueryRequester.changeset(%Vutuv.SearchQueryRequester{}, %{"search_query_id" => id, "user_id" => requester_id})
      |>Ecto.Changeset.put_assoc(:search_results, results_assocs)
    if id, do: changeset, else: query_changeset(changeset, search_query_params)
  end

  def query_changeset(requesters_assoc, search_query_params) do
    SearchQuery.changeset(%SearchQuery{}, search_query_params)
    |>Ecto.Changeset.put_assoc(:requesters, [requesters_assoc])
  end
end

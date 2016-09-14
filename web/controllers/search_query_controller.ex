defmodule Vutuv.SearchQueryController do
  use Vutuv.Web, :controller
  alias Vutuv.Repo
  alias Vutuv.SearchQuery

  def index(conn, _params) do
    changeset = SearchQuery.changeset(%SearchQuery{})
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, %{"search_query" => search_query_params}) do

    results = Repo.all(from u in Vutuv.User, join: e in assoc(u, :emails), where: e.value == ^search_query_params["value"])

    id = Repo.one(from q in Vutuv.SearchQuery, where: q.value == ^search_query_params["value"], select: q.id)
    if id do
      results_assocs = 
      for(user <- results) do
        Ecto.build_assoc(user, :search_query_results)
      end
      changeset = 
      Ecto.build_assoc(conn.assigns[:current_user], :searches)
      |>Vutuv.SearchQueryRequester.changeset(%{"search_query_id" => id})
      |>Ecto.Changeset.put_assoc(:search_results, results_assocs)
      case Repo.insert(changeset) do
        {:ok, _search_query_requester} ->
          conn
          |> put_flash(:info, gettext("Search query updated successfully."))
          |> render("index.html", changeset: SearchQuery.changeset(%SearchQuery{}, %{value: search_query_params["value"]}), results: results)
        {:error, changeset} ->
          render(conn, "index.html", changeset: changeset)
      end
    else
      results_assocs = 
      for(user <- results) do
        Ecto.build_assoc(user, :search_query_results)
      end
      requesters_assoc = 
      Ecto.build_assoc(conn.assigns[:current_user], :searches)
      |>Vutuv.SearchQueryRequester.changeset
      |>Ecto.Changeset.put_assoc(:search_results, results_assocs)
      changeset = SearchQuery.changeset(%SearchQuery{}, search_query_params)
                  |>Ecto.Changeset.put_assoc(:requesters, [requesters_assoc])

      case Repo.insert(changeset) do
        {:ok, _search_query} ->
          conn
          |> put_flash(:info, gettext("Search query created successfully."))
          |> render("index.html", changeset: changeset, results: results)
        {:error, changeset} ->
          render(conn, "index.html", changeset: changeset)
      end
    end
  end
end

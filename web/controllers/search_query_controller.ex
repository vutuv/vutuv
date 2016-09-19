defmodule Vutuv.SearchQueryController do
  use Vutuv.Web, :controller
  alias Vutuv.SearchQuery
  alias Vutuv.SearchQueryRequester
  alias Vutuv.SearchQueryResult
  alias Vutuv.SearchTerm
  alias Vutuv.User

  def index(conn, _params) do
    if(conn.assigns[:current_user]) do
      queries = Repo.all(from q in SearchQuery, join: r in assoc(q, :search_query_requesters), where: r.user_id == ^conn.assigns[:current_user].id, preload: [search_query_requesters: r])
      |>Repo.preload([:search_query_results])
      IO.puts "\n\n#{inspect queries}\n\n"
      render(conn, "index.html", queries: queries)
    else
      redirect(conn, to: search_query_path(conn, :new))
    end
  end

  def show(conn, %{"id" => query_id}) do
    query = 
      Repo.get(SearchQuery, query_id)
      |> Repo.preload([:search_query_results])
    results = 
      for(result <- query.search_query_results) do
        Repo.get(User, result.user_id)
      end
    render(conn, "show.html", query: query, results: results)
  end

  def new(conn, _params) do
    changeset = SearchQuery.changeset(%SearchQuery{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"search_query" => search_query_params}) do
    user = conn.assigns[:current_user]
    results = search search_query_params["value"]
    results_assocs = #build assocs from results
      for(user <- results) do
        Ecto.build_assoc(user, :search_query_results)
      end
    Repo.one(from q in SearchQuery, where: q.value == ^search_query_params["value"])
    |> insert_or_update(search_query_params, requester_assoc(user), results_assocs)
    |> case do #Multiple possible transaction results are covered by 4 different cases
      {:ok, %{search_query: query, search_query_requester: search_query_requester}} ->
        conn
        |> put_flash(:info, gettext("Search query executed successfully."))
        |> redirect(to: search_query_path(conn, :show, query))
      {:ok, query} ->
        conn
        |> put_flash(:info, gettext("Search query executed successfully."))
        |> redirect(to: search_query_path(conn, :show, query))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
      {:error, _failure, changeset, _} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  #build assoc from existing user unless user is nil
  defp requester_assoc(nil) do
    %SearchQueryRequester{}
    |> SearchQueryRequester.changeset(%{user_id: nil})
  end

  defp requester_assoc(user) do
    Ecto.build_assoc(user, :search_query_requesters)
  end

  defp insert_or_update(nil, search_query_params, requester_assoc, results_assocs) do
    %SearchQuery{} #build query changeset from empty struct
    |> SearchQuery.changeset(search_query_params)
    |> Ecto.Changeset.put_assoc(:search_query_requesters, [requester_assoc])
    |> Ecto.Changeset.put_assoc(:search_query_results, results_assocs)
    |> Repo.insert
  end

  defp insert_or_update(query, search_query_params, requester_assoc, results_assocs) do
    requester_changeset = #build requester changeset
      requester_assoc
      |> SearchQueryRequester.changeset(%{search_query_id: query.id})
    query_changeset = #build query changeset from existing query
      query
      |> Repo.preload([:search_query_results, :search_query_requesters])
      |> SearchQuery.changeset(search_query_params)
      |> Ecto.Changeset.put_assoc(:search_query_results, results_assocs)
    Ecto.Multi.new #if one transaction fails, they both fail.
    |> Ecto.Multi.update(:search_query, query_changeset)
    |> Ecto.Multi.insert(:search_query_requester, requester_changeset)
    |> Repo.transaction
  end

  #Check database for matches between search.value and search_terms
  def search(value) do
    value = String.downcase(value)
    for(term<- Repo.all(from t in SearchTerm, where: ^value == t.value)) do
      %{score: term.score, user_id: term.user_id}
    end
    |> Enum.sort(&(&1.score> &2.score)) #sorts by score
    |> Enum.dedup_by(&(&1.user_id)) #filters duplicates
    |> Enum.map(&(Repo.get!(User, &1.user_id))) #maps to flat list of users
  end
end
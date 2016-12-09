defmodule Vutuv.SearchQueryController do
  use Vutuv.Web, :controller
  import Vutuv.Search
  alias Vutuv.SearchQueryRequester
  alias Vutuv.SearchQuery

  @email_regex ~r/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$/

  def index(conn, _params) do
    if(conn.assigns[:current_user]) do
      queries = Repo.all(from q in SearchQuery, join: r in assoc(q, :search_query_requesters), where: r.user_id == ^conn.assigns[:current_user].id, preload: [search_query_requesters: r])
      |>Repo.preload([:search_query_results])
      render(conn, "index.html", queries: queries)
    else
      redirect(conn, to: search_query_path(conn, :new))
    end
  end

  def new(conn, _params) do
    changeset = SearchQuery.changeset(%SearchQuery{})
    render(conn, "new.html", conn: conn, changeset: changeset)
  end

  def create(conn, %{"search_query" => search_query_params}) do
    user = conn.assigns[:current_user]
    search_query_params = Map.put(search_query_params, "is_email?", validate_email(search_query_params["value"]))
    results = search search_query_params["value"], search_query_params["is_email?"]
    Repo.one(from q in SearchQuery, where: q.value == ^search_query_params["value"])
    |> insert_or_update(search_query_params, requester_assoc(user), results)
    |> case do #Multiple possible transaction results are covered by 4 different cases
      {:ok, %{search_query: query, search_query_requester: _search_query_requester}} ->
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

  def show(conn, %{"id" => query_id}) do
    empty_changeset = SearchQuery.changeset(%SearchQuery{})
    Repo.one(from q in SearchQuery, where: q.value == ^query_id)
    |> case do #if query is nil, it doesn't yet exist, so create it.
      nil -> create(conn, %{"search_query" => %{"value" => query_id}})
      query ->
        changeset = 
          query
          |> Repo.preload([:search_query_results, :search_query_requesters])
          |> SearchQuery.changeset
        query = Repo.preload(query, [:search_query_results, :user_results, :skill_results])
        conn
        |> Map.put(:params, Map.put_new(conn.params, "skills", "#{Enum.count(query.user_results) < Enum.count(query.skill_results)}"))
        |> render("new.html", query: query, user_results: query.user_results, skill_results: query.skill_results, changeset: empty_changeset, value: query.value)
    end
  end

  defp validate_email(nil), do: false

  defp validate_email(value) do
    Regex.match?(@email_regex, value)
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

  #build assoc from existing user unless user is nil
  defp requester_assoc(nil) do
    %SearchQueryRequester{}
    |> SearchQueryRequester.changeset(%{user_id: nil})
  end

  defp requester_assoc(user) do
    Ecto.build_assoc(user, :search_query_requesters)
  end
end
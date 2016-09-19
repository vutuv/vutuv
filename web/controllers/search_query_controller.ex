defmodule Vutuv.SearchQueryController do
  use Vutuv.Web, :controller
  alias Vutuv.SearchQuery

  plug :check_user

  def index(conn, _params) do
    id = if conn.assigns[:current_user], do: conn.assigns[:current_user].id, else: nil
    queries = Repo.all(from q in SearchQuery, join: r in assoc(:requesters), where: r.user_id == id)
    render(conn, "index.html", queries: queries)
  end

  def show(conn, _params, query) do
    
    render conn, "show.html", 
  end

  def new(conn, _params) do
    changeset = SearchQuery.changeset(%SearchQuery{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"search_query" => search_query_params}) do
    id = if conn.assigns[:current_user], do: conn.assigns[:current_user].id, else: nil
    results = search search_query_params["value"]
    results_assocs = 
      for(user <- results) do
        Ecto.build_assoc(user, :search_query_results)
      end
    Repo.one(from q in Vutuv.SearchQuery, where: q.value == ^search_query_params["value"], select: q.id)
    |> requester_changeset(id, search_query_params, results_assocs)
    |> Repo.insert
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, gettext("Search query executed successfully."))
        |> render("results.html", results: results)
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def requester_changeset(id, requester_id, search_query_params, results_assocs) do
    %Vutuv.SearchQueryRequester{}
    |> Vutuv.SearchQueryRequester.changeset(%{"search_query_id" => id, "user_id" => requester_id})
    |> Ecto.Changeset.put_assoc(:search_results, results_assocs)
    |> query_changeset(search_query_params, id)
  end

  def query_changeset(requesters_assoc, search_query_params, nil) do
    %SearchQuery{}
    |> SearchQuery.changeset(search_query_params)
    |> Ecto.Changeset.put_assoc(:requesters, [requesters_assoc])
  end

  def query_changeset(changeset, _, _), do: changeset

  def search(value) do
    value = String.downcase(value)
    for(term<- Repo.all(from t in Vutuv.SearchTerm, where: ^value == t.value)) do
      %{score: term.score, user_id: term.user_id}
    end
    |>Enum.sort(&(&1.score> &2.score)) #sorts by score
    |>Enum.dedup_by(&(&1.user_id)) #filters duplicates
    |>Enum.map(&(Repo.get!(Vutuv.User, &1.user_id))) #maps to flat list of users
  end

  defp check_user(conn, _opts) do
    IO.puts "\n\n#{inspect conn}\n\n"
    case conn.assigns[:current_user] do
      nil -> conn
      user -> 
        case hd(conn.path_info) do
          "users" -> conn
          _ -> redirect conn, to: user_search_query_path(conn, conn.private.phoenix_action, user)
        end
    end
  end
end
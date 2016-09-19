defmodule Vutuv.SearchTermController do
  use Vutuv.Web, :controller

  alias Vutuv.SearchTerm

  def index(conn, _params) do
    search_terms = Repo.all(SearchTerm)
    render(conn, "index.html", search_terms: search_terms, user: conn.assigns[:current_user])
  end

  def new(conn, _params) do
    changeset = SearchTerm.changeset(%SearchTerm{})
    render(conn, "new.html", changeset: changeset, user: conn.assigns[:current_user])
  end

  def create(conn, %{"search_term" => search_term_params}) do
    changeset = 
      conn.assigns[:user]
      |>build_assoc(:search_terms)
      |>SearchTerm.changeset(search_term_params)

    case Repo.insert(changeset) do
      {:ok, _search_term} ->
        conn
        |> put_flash(:info, gettext("Search term created successfully."))
        |> redirect(to: user_search_term_path(conn, :index, conn.assigns[:current_user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, user: conn.assigns[:current_user])
    end
  end

  def show(conn, %{"id" => id}) do
    search_term = Repo.get!(SearchTerm, id)
    render(conn, "show.html", search_term: search_term, user: conn.assigns[:current_user])
  end

  def edit(conn, %{"id" => id}) do
    search_term = Repo.get!(SearchTerm, id)
    changeset = SearchTerm.changeset(search_term)
    render(conn, "edit.html", search_term: search_term, changeset: changeset, user: conn.assigns[:current_user])
  end

  def update(conn, %{"id" => id, "search_term" => search_term_params}) do
    search_term = Repo.get!(SearchTerm, id)
    changeset = SearchTerm.changeset(search_term, search_term_params)

    case Repo.update(changeset) do
      {:ok, search_term} ->
        conn
        |> put_flash(:info, gettext("Search term updated successfully."))
        |> redirect(to: user_search_term_path(conn, :show, conn.assigns[:current_user], search_term))
      {:error, changeset} ->
        render(conn, "edit.html", search_term: search_term, changeset: changeset, user: conn.assigns[:current_user])
    end
  end

  def delete(conn, %{"id" => id}) do
    search_term = Repo.get!(SearchTerm, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(search_term)

    conn
    |> put_flash(:info, gettext("Search term deleted successfully."))
    |> redirect(to: user_search_term_path(conn, :index, conn.assigns[:current_user]))
  end
end

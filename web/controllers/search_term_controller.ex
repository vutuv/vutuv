defmodule Vutuv.SearchTermController do
  use Vutuv.Web, :controller

  alias Vutuv.SearchTerm

  def index(conn, _params) do
    search_terms = Repo.all(from s in SearchTerm, where: s.user_id == ^conn.assigns[:current_user].id)
    render(conn, "index.html", search_terms: search_terms, user: conn.assigns[:current_user])
  end

  def show(conn, %{"id" => id}) do
    search_term = Repo.get!(SearchTerm, id)
    render(conn, "show.html", search_term: search_term, user: conn.assigns[:current_user])
  end
end

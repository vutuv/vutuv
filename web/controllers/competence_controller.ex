defmodule Vutuv.CompetenceController do
  use Vutuv.Web, :controller

  alias Vutuv.Competence

  def index(conn, _params) do
    competences = Repo.all(Competence)
    render(conn, "index.html", competences: competences)
  end

  def new(conn, _params) do
    changeset = Competence.changeset(%Competence{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"competence" => competence_params}) do
    changeset = Competence.changeset(%Competence{}, competence_params)

    case Repo.insert(changeset) do
      {:ok, _competence} ->
        conn
        |> put_flash(:info, gettext("Competence created successfully."))
        |> redirect(to: competence_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    competence = Repo.get!(Competence, id)
    render(conn, "show.html", competence: competence)
  end

  def edit(conn, %{"id" => id}) do
    competence = Repo.get!(Competence, id)
    changeset = Competence.changeset(competence)
    render(conn, "edit.html", competence: competence, changeset: changeset)
  end

  def update(conn, %{"id" => id, "competence" => competence_params}) do
    competence = Repo.get!(Competence, id)
    changeset = Competence.changeset(competence, competence_params)

    case Repo.update(changeset) do
      {:ok, competence} ->
        conn
        |> put_flash(:info, gettext("Competence updated successfully."))
        |> redirect(to: competence_path(conn, :show, competence))
      {:error, changeset} ->
        render(conn, "edit.html", competence: competence, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    competence = Repo.get!(Competence, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(competence)

    conn
    |> put_flash(:info, gettext("Competence deleted successfully."))
    |> redirect(to: competence_path(conn, :index))
  end
end

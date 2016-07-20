defmodule Vutuv.CompetenceController do
  use Vutuv.Web, :controller
  plug :assign_user

  alias Vutuv.Competence

  def index(conn, _params) do
    user =
      Repo.get!(Vutuv.User, conn.assigns[:user].id)
      |> Repo.preload([:competences])

    render(conn, "index.html", competences: user.competences)
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
        |> redirect(to: user_competence_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    competence = Repo.get!(Competence, id)
    render(conn, "show.html", competence: competence)
  end

  def delete(conn, %{"id" => id}) do
    competence = Repo.get!(Competence, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(competence)

    conn
    |> put_flash(:info, gettext("Competence deleted successfully."))
    |> redirect(to: user_competence_path(conn, :index, conn.assigns[:user]))
  end

  defp assign_user(conn, _opts) do
    case conn.params do
      %{"user_id" => user_id} ->
        case Repo.get(Vutuv.User, user_id) do
          nil  -> invalid_user(conn)
          user -> assign(conn, :user, user)
        end
      _ -> invalid_user(conn)
    end
  end

  defp invalid_user(conn) do
    conn
    |> put_flash(:error, "Invalid user!")
    |> redirect(to: page_path(conn, :index))
    |> halt
  end

end

defmodule Vutuv.WorkExperienceController do
  use Vutuv.Web, :controller
  alias Vutuv.WorkExperience
  
  plug Vutuv.Plug.AuthUser when action in [:new, :create, :edit, :update, :delete]
  plug :scrub_params, "work_experience" when action in [:create, :update]
  

  def index(conn, _params) do
    user = 
      conn.assigns[:user]
      |> Repo.preload([:work_experiences])
    render(conn, "index.html", user: user, work_experience: user.work_experiences)
  end

  def new(conn, _params) do
    changeset = WorkExperience.changeset(%WorkExperience{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"work_experience" => work_experience_params}) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:work_experiences)
      |> WorkExperience.changeset(work_experience_params)

    case Repo.insert(changeset) do
      {:ok, _work_experience} ->
        conn
        |> put_flash(:info, gettext("Work experience created successfully."))
        |> redirect(to: user_work_experience_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    work_experience = Repo.get!(WorkExperience, id)
    render(conn, "show.html", work_experience: work_experience)
  end

  def edit(conn, %{"id" => id}) do
    work_experience = Repo.get!(WorkExperience, id)
    changeset = WorkExperience.changeset(work_experience)
    render(conn, "edit.html", work_experience: work_experience, changeset: changeset)
  end

  def update(conn, %{"id" => id, "work_experience" => work_experience_params}) do
    work_experience = Repo.get!(assoc(conn.assigns[:user], :work_experiences), id)
    changeset = WorkExperience.changeset(work_experience, work_experience_params)
    case Repo.update(changeset) do
      {:ok, work_experience} ->
        conn
        |> put_flash(:info, gettext("Work experience updated successfully."))
        |> redirect(to: user_work_experience_path(conn, :show, conn.assigns[:user], work_experience))
      {:error, changeset} ->
        render(conn, "edit.html", work_experience: work_experience, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    work_experience = Repo.get!(WorkExperience, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(work_experience)

    conn
    |> put_flash(:info, gettext("Work experience deleted successfully."))
    |> redirect(to: user_work_experience_path(conn, :index, conn.assigns[:user]))
  end
end

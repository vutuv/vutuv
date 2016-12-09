defmodule Vutuv.WorkExperienceController do
  use Vutuv.Web, :controller
  alias Vutuv.WorkExperience
  
  plug Vutuv.Plug.AuthUser when not action in [:index, :show]
  plug :scrub_params, "work_experience" when action in [:create, :update]
  plug :resolve_slug
  

  def index(conn, _params) do
    user = 
      conn.assigns[:user]
      |> Repo.preload([work_experiences: from(u in Vutuv.WorkExperience) |> WorkExperience.order_by_date])

    render(conn, "index.html", user: user, work_experience: user.work_experiences)
  end

  def new(conn, _params) do
    changeset = WorkExperience.changeset(%WorkExperience{})
    current_year = DateTime.utc_now |> Map.fetch!(:year)
    render(conn, "new.html", changeset: changeset, current_year: current_year)
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
        current_year = DateTime.utc_now |> Map.fetch!(:year)
        render(conn, "new.html", changeset: changeset, current_year: current_year)
    end
  end

  def show(conn, _params) do
    work_experience = conn.assigns[:job]
      |> Repo.preload([:user])
    if(work_experience.user.id == conn.assigns[:user].id) do
      render(conn, "show.html", work_experience: work_experience)
    else
      redirect(conn, to: user_work_experience_path(conn, :show, work_experience.user, work_experience))
    end
  end

  def edit(conn, _params) do
    work_experience = conn.assigns[:job]
    changeset = WorkExperience.changeset(work_experience)
    current_year = DateTime.utc_now |> Map.fetch!(:year)
    render(conn, "edit.html", work_experience: work_experience, changeset: changeset, current_year: current_year)
  end

  def update(conn, %{"work_experience" => work_experience_params}) do
    work_experience = conn.assigns[:job]
    changeset = WorkExperience.changeset(work_experience, work_experience_params)
    case Repo.update(changeset) do
      {:ok, work_experience} ->
        conn
        |> put_flash(:info, gettext("Work experience updated successfully."))
        |> redirect(to: user_work_experience_path(conn, :show, conn.assigns[:user], work_experience))
      {:error, changeset} ->
        current_year = DateTime.utc_now |> Map.fetch!(:year)
        render(conn, "edit.html", work_experience: work_experience, changeset: changeset, current_year: current_year)
    end
  end

  def delete(conn, _params) do

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(conn.assigns[:job])

    conn
    |> put_flash(:info, gettext("Work experience deleted successfully."))
    |> redirect(to: user_work_experience_path(conn, :index, conn.assigns[:user]))
  end

  defp resolve_slug(%{params: %{"id" => id}} = conn, _) do
    Repo.one(from w in assoc(conn.assigns[:user], :work_experiences), where: w.slug == ^id)
    |>case do
      nil -> 
        conn
        |> put_status(404)
        |> render(Vutuv.ErrorView, "404.html")
      job -> assign(conn, :job, job)
    end
    
  end

  defp resolve_slug(conn, _), do: conn
end

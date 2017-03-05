defmodule Vutuv.JobPostingController do
  use Vutuv.Web, :controller
  plug Vutuv.Plug.AuthRecruiter when action in [:edit, :update, :new, :create, :delete]
  plug :validate_recruiter
  plug Vutuv.Plug.ResolveSlug,
      slug: "job_slug",
      model: Vutuv.JobPosting,
      assign: :job_posting,
      field: :slug
  plug :validate_package when action in [:new, :create, :index]

  alias Vutuv.JobPosting

  def index(conn, _params) do
    user = Repo.preload(conn.assigns[:user], :job_postings)
    render(conn, "index.html", job_postings: user.job_postings)
  end

  def new(conn, _params) do
    changeset = JobPosting.changeset(%JobPosting{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"job_posting" => job_posting_params}) do
    changeset =
    conn.assigns[:user]
    |> Ecto.build_assoc(:job_postings)
    |> JobPosting.changeset(job_posting_params, conn.assigns[:locale])

    case Repo.insert(changeset) do
      {:ok, _job_posting} ->
        conn
        |> put_flash(:info, gettext("Job posting created successfully."))
        |> redirect(to: user_job_posting_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    job_posting =
      conn.assigns[:job_posting]
      |> Repo.preload([job_posting_tags: :tag])
    render(conn, "show.html", job_posting: job_posting)
  end

  def edit(conn, _params) do
    job_posting = conn.assigns[:job_posting]
    changeset = JobPosting.changeset(job_posting)
    render(conn, "edit.html", job_posting: job_posting, changeset: changeset)
  end

  def update(conn, %{"job_posting" => job_posting_params}) do
    job_posting = conn.assigns[:job_posting]
    changeset = JobPosting.changeset(job_posting, job_posting_params)

    case Repo.update(changeset) do
      {:ok, job_posting} ->
        conn
        |> put_flash(:info, gettext("Job posting updated successfully."))
        |> redirect(to: user_job_posting_path(conn, :show, conn.assigns[:user], job_posting))
      {:error, changeset} ->
        render(conn, "edit.html", job_posting: job_posting, changeset: changeset)
    end
  end

  def delete(conn, params) do
    job_posting = conn.assigns[:job_posting]

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(job_posting)

    conn
    |> put_flash(:info, gettext("Job posting deleted successfully."))
    |> redirect(to: user_job_posting_path(conn, :index, conn.assigns[:user]))
  end

  defp validate_recruiter(conn, _opts) do
    case Vutuv.RecruiterSubscription.active_subscription(conn.assigns[:user_id]) do
      nil ->
        conn
        |> put_status(403)
        |> render(Vutuv.ErrorView, "403.html")
        |> halt
      subscription -> assign(conn, :active_subscription, subscription)
    end
  end

  defp validate_package(conn, _opts) do
    user = Repo.preload(conn.assigns[:user], [:job_postings])
    if(Enum.count(user.job_postings) >= conn.assigns[:active_subscription].recruiter_package.max_job_postings) do
      conn
      |> put_flash(:info, "You have reached your limit for posting jobs. If you wish to post a new job, you must delete an existing one or upgrade your plan.")
      |> render("index.html", job_postings: user.job_postings)
      |> halt
    else
      conn
    end
  end
end

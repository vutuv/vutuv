defmodule Vutuv.JobPostingTagController do
  use Vutuv.Web, :controller

  plug Vutuv.Plug.ResolveSlug,
      slug: "job_posting_job_slug",
      model: Vutuv.JobPosting,
      assign: :job_posting,
      field: :slug
  plug :resolve_slug

  alias Vutuv.JobPostingTag

  def index(conn, _params) do
    job_posting =
      conn.assigns[:job_posting]
      |> Repo.preload([job_posting_tags: :tag])
    render(conn, "index.html", job_posting_tags: job_posting.job_posting_tags)
  end

  def new(conn, _params) do
    changeset = JobPostingTag.changeset(%JobPostingTag{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"job_posting_tag" => job_posting_tag_params}) do
    changeset =
      conn.assigns[:job_posting]
      |> Ecto.build_assoc(:job_posting_tags)
      |> JobPostingTag.changeset(job_posting_tag_params)

    case Repo.insert(changeset) do
      {:ok, _job_posting_tag} ->
        conn
        |> put_flash(:info, gettext("Job posting tag created successfully."))
        |> redirect(to: user_job_posting_tag_path(conn, :index, conn.assigns[:user], conn.assigns[:job_posting]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    job_posting_tag =
      conn.assigns[:job_posting_tag]
      |> Repo.preload([:tag])
    render(conn, "show.html", job_posting_tag: job_posting_tag)
  end

  def edit(conn, _params) do
    job_posting_tag = conn.assigns[:job_posting_tag]
    changeset = JobPostingTag.changeset(job_posting_tag)
    render(conn, "edit.html", job_posting_tag: job_posting_tag, changeset: changeset)
  end

  def update(conn, %{"job_posting_tag" => job_posting_tag_params}) do
    job_posting_tag = conn.assigns[:job_posting_tag]
    changeset = JobPostingTag.changeset(job_posting_tag, job_posting_tag_params)

    case Repo.update(changeset) do
      {:ok, job_posting_tag} ->
        conn
        |> put_flash(:info, gettext("Job posting tag updated successfully."))
        |> redirect(to: user_job_posting_tag_path(conn, :show, conn.assigns[:user], conn.assigns[:job_posting], job_posting_tag))
      {:error, changeset} ->
        render(conn, "edit.html", job_posting_tag: job_posting_tag, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    job_posting_tag = conn.assigns[:job_posting_tag]

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(job_posting_tag)

    conn
    |> put_flash(:info, gettext("Job posting tag deleted successfully."))
    |> redirect(to: user_job_posting_tag_path(conn, :index, conn.assigns[:user], conn.assigns[:job_posting]))
  end

  defp resolve_slug(%{params: %{"id" => slug}} = conn, _) do
    Repo.one(from w in assoc(conn.assigns[:job_posting], :job_posting_tags), join: t in assoc(w, :tag), where: t.slug == ^slug)
    |>case do
      nil ->
        conn
        |> put_status(404)
        |> render(Vutuv.ErrorView, "404.html")
      job_posting_tag -> assign(conn, :job_posting_tag, job_posting_tag)
    end
  end

  defp resolve_slug(conn, _), do: conn
end

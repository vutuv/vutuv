defmodule Vutuv.JobPosting do
  use Vutuv.Web, :model
  @derive {Phoenix.Param, key: :slug}

  alias Vutuv.JobPostingTag

  schema "job_postings" do
    field :title, :string
    field :description, :string
    field :location, :string
    field :prerequisites, :string
    field :slug, :string
    field :open_on, Ecto.Date
    field :closed_on, Ecto.Date

    belongs_to :user, Vutuv.User

    has_many :job_posting_tags, JobPostingTag
    has_many :tags, through: [:job_posting_tags, :tag]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}, locale \\ nil) do
    struct
    |> cast(params, [:user_id, :title, :description, :location, :prerequisites, :slug, :open_on, :closed_on])
    |> gen_slug()
    |> validate_required([:user_id, :title, :description, :location, :prerequisites, :slug])
    |> validate_length(:title, max: 40)
    |> validate_length(:description, max: 8192)
    |> validate_length(:prerequisites, max: 8192)
    |> validate_length(:location, max: 8192)
    |> validate_dates()
    |> put_tags(params, locale)
  end

  defp gen_slug(changeset) do
    value = get_field(changeset, :title)
    slug =
      value
      |> Vutuv.SlugHelpers.gen_slug_unique( __MODULE__, :slug, ?_)
    put_change(changeset, :slug, slug)
  end

  defp validate_dates(changeset) do
    open = get_change(changeset, :open_on)
    closed = get_change(changeset, :closed_on)
    if(open && closed && Ecto.Date.compare(open, closed) == :lt) do
      changeset
    else
      add_error(changeset, :open_on, "Open date must be less than Closed date.")
    end
  end

  defp put_tags(changeset, %{"important_tags" => important, "optional_tags" => optional, "other_tags" => other}, locale) do
    IO.puts "\n\n\n"
    IO.inspect parse_tags(important, 2, locale)
    IO.inspect parse_tags(optional, 1, locale)
    IO.inspect parse_tags(other, 0, locale)
    IO.puts "\n\n\n"
    changeset
    |> put_assoc(:job_posting_tags,
    parse_tags(important, 2, locale)++
    parse_tags(optional, 1, locale)++
    parse_tags(other, 0, locale))
  end

  defp put_tags(changeset, _, nil), do: changeset

  defp parse_tags(tags, priority, locale) do
    tag_list =
      tags
      |> String.split(",")
    results =
    for(tag <- tag_list) do
      capitalized_tag =
        tag
        |> String.trim

      %JobPostingTag{}
      |> JobPostingTag.changeset(%{priority: priority})
      |> Vutuv.Tag.create_or_link_tag(%{"value" => capitalized_tag}, locale)
    end
  end

  def get_postings_for_user(user) do
    tags = Vutuv.Repo.preload(user, [:tags]).tags
    tag_ids = for tag <- tags, do: tag.id
    Vutuv.Repo.all(from j in __MODULE__,
      left_join: jt in Vutuv.JobPostingTag, on: jt.job_posting_id == j.id,
      where: jt.tag_id in ^tag_ids,
      limit: 2,
      group_by: j.id,
      order_by: [
        desc: fragment("SUM(CASE WHEN ? = 2 THEN 1 ELSE 0 END)",jt.priority),
        desc: fragment("SUM(CASE WHEN ? = 1 THEN 1 ELSE 0 END)",jt.priority),
        desc: fragment("SUM(CASE WHEN ? = 0 THEN 1 ELSE 0 END)",jt.priority)])
    |> ensure_jobs_returned()
  end

  defp ensure_jobs_returned([]) do
    Vutuv.Repo.all(from j in __MODULE__, limit: 2)
  end

  defp ensure_jobs_returned([head | []]) do
    [head | Vutuv.Repo.all(from j in __MODULE__, where: not (j.id == ^head.id), limit: 1)]
  end

  defp ensure_jobs_returned(jobs), do: jobs

  def get_important_tags(job) do
    Vutuv.Repo.all(from t in Vutuv.Tag, left_join: j in assoc(t, :job_posting_tags), where: j.job_posting_id == ^job.id and j.priority == 2, limit: 3)
  end
end

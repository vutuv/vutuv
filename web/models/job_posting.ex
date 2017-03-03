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

  @max_important_tags 3

  @max_optional_tags 7

  @max_othert_tags 7


  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}, locale \\ nil) do
    struct
    |> cast(params, [:user_id, :title, :description, :location, :prerequisites, :slug, :open_on, :closed_on])
    |> gen_slug()
    |> validate_required([:user_id, :title, :slug])
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
    open = get_field(changeset, :open_on)
    closed = get_field(changeset, :closed_on)
    if(open && closed && Ecto.Date.compare(open, closed) == :lt) do
      changeset
    else
      add_error(changeset, :open_on, "Open date must be less than Closed date.")
    end
  end

  defp put_tags(changeset, %{"important_tags" => important_tags, "optional_tags" => optional_tags, "other_tags" => other_tags}, locale) do
    important = parse_tags(important_tags)
    optional = parse_tags(optional_tags)
    other = parse_tags(other_tags)
    changeset
    |> validate_tag_uniqueness(important, optional, other)
    |> validate_important_tags(important)
    |> validate_optional_tags(optional)
    |> validate_other_tags(other)
    |> put_assocs(important, optional, other, locale)
  end

  defp put_tags(changeset, _, _), do: changeset

  defp parse_tags(tags) do
    tag_list =
      tags
      |> String.split(",")
    for(tag <- tag_list) do
      String.trim tag
    end
  end

  defp validate_tag_uniqueness(changeset, important, optional, other) do
    tags = important ++ optional ++ other
    if(Enum.count(tags) == Enum.count(Enum.uniq(tags))) do
      changeset
    else
      add_error(changeset, :job_posting_id_tag_id, "Tags must all be different")
    end
  end

  defp validate_important_tags(changeset, important) do
    if(Enum.count(important) != @max_important_tags) do
      add_error(changeset, :important_tags, "You must have #{@max_important_tags} important tags.")
    else
      changeset
    end
  end

  defp validate_optional_tags(changeset, optional) do
    if(Enum.count(optional) > @max_optional_tags) do
      add_error(changeset, :optional_tags, "You can have a maximum of #{@max_optional_tags} optional tags.")
    else
      changeset
    end
  end

  defp validate_other_tags(changeset, other) do
    if(Enum.count(other) > @max_other_tags) do
      add_error(changeset, :other_tags, "You can have a maximum of #{@max_other_tags} other tags.")
    else
      changeset
    end
  end

  defp put_assocs(%Ecto.Changeset{valid?: false} = changeset, _, _, _, _), do: changeset

  defp put_assocs(changeset, important, optional, other, locale) do
    changeset
    |> put_assoc(:job_posting_tags,
      tag_changesets(important, 2, locale)++
      tag_changesets(optional, 1, locale)++
      tag_changesets(other, 0, locale))
  end

  defp tag_changesets(tags, priority, locale) do
    for(tag <- tags) do
      %JobPostingTag{}
      |> JobPostingTag.changeset(%{priority: priority})
      |> Vutuv.Tag.create_or_link_tag(%{"value" => tag}, locale)
    end
  end

  def get_postings_for_user(user) do
    tags = Vutuv.Repo.preload(user, [:tags]).tags
    tag_ids = for tag <- tags, do: tag.id
    Vutuv.Repo.all(from j in __MODULE__,
      left_join: jt in Vutuv.JobPostingTag, on: jt.job_posting_id == j.id,
      left_join: u in assoc(j, :user),
      left_join: s in assoc(u, :recruiter_subscriptions),
      where: jt.tag_id in ^tag_ids and s.paid == true,
      limit: 2,
      group_by: j.id,
      order_by: [
        desc: fragment("SUM(CASE WHEN ? = 2 THEN 1 ELSE 0 END)",jt.priority),
        desc: fragment("SUM(CASE WHEN ? = 1 THEN 1 ELSE 0 END)",jt.priority),
        desc: fragment("SUM(CASE WHEN ? = 0 THEN 1 ELSE 0 END)",jt.priority)])
    |> ensure_jobs_returned()
  end

  defp ensure_jobs_returned([]) do
    Vutuv.Repo.all(from j in __MODULE__,
      left_join: u in assoc(j, :user),
      left_join: s in assoc(u, :recruiter_subscriptions),
      where: s.paid == true,
      limit: 2)
  end

  defp ensure_jobs_returned([head | []]) do
    [head | Vutuv.Repo.all(from j in __MODULE__,
      left_join: u in assoc(j, :user),
      left_join: s in assoc(u, :recruiter_subscriptions),
      where: not (j.id == ^head.id) and s.paid == true, limit: 1)]
  end

  defp ensure_jobs_returned(jobs), do: jobs

  def get_important_tags(job) do
    Vutuv.Repo.all(from t in Vutuv.Tag, left_join: j in assoc(t, :job_posting_tags), where: j.job_posting_id == ^job.id and j.priority == 2, limit: 3)
  end
end

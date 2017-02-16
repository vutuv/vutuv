defmodule Vutuv.JobPostingTag do
  use Vutuv.Web, :model

  schema "job_posting_tags" do
    field :priority, :integer

    belongs_to :job_posting, Vutuv.JobPosting
    belongs_to :tag, Vutuv.Tag

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:job_posting_id, :tag_id, :priority])
    |> validate_required([:priority])
  end

  defimpl Phoenix.Param, for: __MODULE__ do
    def to_param(job_posting_tag) do
      Vutuv.Repo.preload(job_posting_tag, [:tag]).tag.slug
    end
  end
end

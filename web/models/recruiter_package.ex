defmodule Vutuv.RecruiterPackage do
  use Vutuv.Web, :model

  schema "recruiter_packages" do
    field :name, :string
    field :description, :string
    field :slug, :string
    field :price, :float
    field :currency, :string
    field :duration_in_months, :integer
    field :auto_renewal, :boolean
    field :offer_begins, Ecto.Date
    field :offer_ends, Ecto.Date
    field :max_job_postings, :integer

    belongs_to :locale, Vutuv.Locale

    has_many :recruiter_subscriptions, Vutuv.RecruiterSubscription

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :slug, :locale_id, :price, :currency, :duration_in_months, :auto_renewal, :offer_begins, :offer_ends, :max_job_postings])
    #|> validate_required([:name, :description, :slug, :locale_id, :price, :currency, :duration_in_months, :auto_renewal, :offer_begins, :offer_ends, :max_job_postings])
  end

  def get_packages(locale) do
    Vutuv.Repo.all(from r in Vutuv.RecruiterPackage, where: r.locale_id == ^Vutuv.Locale.locale_id(locale))
  end
end

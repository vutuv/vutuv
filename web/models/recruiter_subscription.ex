defmodule Vutuv.RecruiterSubscription do
  use Vutuv.Web, :model

  schema "recruiter_subscriptions" do
    field :subscription_begins, Ecto.Date
    field :subscription_ends, Ecto.Date
    field :line1, :string
    field :line2, :string
    field :street, :string
    field :zip_code, :string
    field :city, :string
    field :country, :string
    field :invoice_number, :string
    field :invoiced_on, Ecto.Date
    field :paid, :boolean, default: false
    field :paid_on, Ecto.Date

    belongs_to :user, Vutuv.User
    belongs_to :recruiter_package, Vutuv.RecruiterPackage

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :recruiter_package_id, :subscription_begins, :line1, :line2, :street, :zip_code, :city, :country, :invoice_number, :invoiced_on, :paid, :paid_on])
    |> validate_required([:recruiter_package_id, :line1, :street, :zip_code, :city, :country])
    |> foreign_key_constraint(:recruiter_package)
    |> set_dates()
  end

  defp set_dates(changeset) do
    case get_change(changeset, :recruiter_package_id) do
      nil ->
        changeset
      id ->
        with package           <- Vutuv.Repo.get(Vutuv.RecruiterPackage, id),
             years             <- div(package.duration_in_months, 12),
             months            <- rem(package.duration_in_months, 12),
             {year, month, _}  <- Ecto.Date.to_erl(Ecto.Date.utc()),
             {:ok, end_date}   <- Ecto.Date.cast({year+years, month+months, 1}) do
             put_change(changeset, :subscription_ends, end_date)
             |> put_change(:subscription_begins, Ecto.Date.utc())
        else
          _ -> add_error(changeset, :recruiter_package_id, "Something went wrong")
        end
    end
  end

  def active_subscription(user_id) do
    case Vutuv.Repo.one(from s in __MODULE__, where: s.user_id == ^user_id and s.subscription_ends > fragment("NOW()"), limit: 1) do
      nil -> nil
      sub -> Vutuv.Repo.preload(sub, [:recruiter_package])
    end
  end
end

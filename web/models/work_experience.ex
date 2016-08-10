defmodule Vutuv.WorkExperience do
  use Vutuv.Web, :model

  schema "work_experiences" do
    field :organization, :string
    field :title, :string
    field :description, :string
    field :start_month, :integer
    field :start_year, :integer
    field :end_month, :integer
    field :end_year, :integer

    has_one :company, Vutuv.Company

    belongs_to :user, Vutuv.User

    timestamps
  end

  @required_fields ~w(title description start_month start_year)
  @optional_fields ~w(organization end_month end_year)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required([:title, :description, :start_year, :start_month, :organization])
    |> validate_end_dates
  end

  def validate_end_dates(changeset) do
    end_month = get_field(changeset, :end_month)
    end_year = get_field(changeset, :end_year)
    if(end_month || end_year) do
      if(end_month && end_year) do
        validate_date_range(changeset)
      else
        message = "Both end month and end year must be present or empty"
        changeset
        |> add_error(:end_month, message)
        |> add_error(:end_year, message)
      end
    else
      changeset
    end
  end

  def validate_date_range(changeset) do
    end_month = get_field(changeset, :end_month)
    end_year = get_field(changeset, :end_year)
    start_month = get_field(changeset, :start_month)
    start_year = get_field(changeset, :start_year)
    cond do
      start_year>end_year ->
        add_error(changeset, :end_year, "End date must be later than start date")
      (start_year==end_year)&&(start_month>end_month) ->
        add_error(changeset, :end_month, "End date must be later than start date")
      start_year<=end_year ->
        changeset
    end
  end
end

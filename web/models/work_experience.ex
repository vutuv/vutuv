defmodule Vutuv.WorkExperience do
  use Vutuv.Web, :model

  schema "work_experiences" do
    field :organization, :string
    field :title, :string
    field :description, :string
    field :start_month, :integer, allow_nil: true
    field :start_year, :integer, allow_nil: true
    field :end_month, :integer, allow_nil: true
    field :end_year, :integer, allow_nil: true

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
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required([:title, :organization])
    |> validate_dates
  end

  def validate_dates(changeset) do
    end_month = get_field(changeset, :end_month)
    end_year = get_field(changeset, :end_year)
    start_month = get_field(changeset, :start_month)
    start_year = get_field(changeset, :start_year)

    changeset =  
      if(!presence_correct?(start_year, start_month), 
      do: add_error(changeset, :start_year, "If month is present, year must be present."),
      else: changeset)
    changeset =
      if(!presence_correct?(end_year, end_month),
      do: add_error(changeset, :start_year, "If month is present, year must be present."),
      else: changeset)
    changeset =
      if(!date_range_correct?(start_year, end_year),
      do: add_error(changeset, :end_month, "End date must be later than start date"),
      else: changeset)
    if((start_year&&end_year) && (start_year == end_year)) do
      if(!date_range_correct?(start_month, end_month),
      do: add_error(changeset, :end_month, "End date must be later than start date"),
      else: changeset)
    else
      changeset
    end
  end

  defp presence_correct?(year, month) do
    cond do
      year && month -> true
      year -> true
      month -> false
      true -> true
    end
  end

  defp date_range_correct?(start, finish) do
    if(start && finish) do
      cond do
        start>finish -> false
        start<=finish -> true
      end
    else
      true
    end
  end

  def has_end_date?(%__MODULE__{end_year: nil}), do: false
  def has_end_date?(%__MODULE__{end_year: _}), do: true

end

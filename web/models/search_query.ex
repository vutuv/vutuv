defmodule Vutuv.SearchQuery do
  use Vutuv.Web, :model

  schema "search_queries" do
    field :value, :string
    field :is_email?, :boolean

    has_many :results, Vutuv.User, on_delete: :nothing
    has_many :requesters, Vutuv.SearchQueryRequester, on_delete: :nothing
    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w()
  @email_regex ~r/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$/

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:value, :is_email?])
    |> unique_constraint(:value)
    |> validate_email
  end

  def validate_email(changeset) do
    value = get_field(changeset, :value)
    if(Regex.match?(@email_regex, value))do
      put_change(changeset, :is_email?, true)
    else
      put_change(changeset, :is_email?, false)
    end
  end
end

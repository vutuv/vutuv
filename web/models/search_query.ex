defmodule Vutuv.SearchQuery do
  use Vutuv.Web, :model

  schema "search_queries" do
    field :value, :string
    field :is_email?, :boolean
    
    has_many :search_query_results, Vutuv.SearchQueryResult, on_delete: :delete_all, on_replace: :delete
    has_many :search_query_requesters, Vutuv.SearchQueryRequester, on_delete: :delete_all
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
    |> cast_assoc(:search_query_results)
    |> cast_assoc(:search_query_requesters)
    |> unique_constraint(:value)
    |> downcase_value
    |> validate_email
  end

  def validate_email(changeset) do
    value = get_field(changeset, :value)
    cond do
      value == nil -> put_change(changeset, :is_email?, false)
      Regex.match?(@email_regex, value) -> put_change(changeset, :is_email?, true)
      true -> put_change(changeset, :is_email?, false)
    end
  end

  def downcase_value(changeset) do
    # If the value has been changed, downcase it.
    update_change(changeset, :value, &String.downcase/1)
  end
end

defmodule Vutuv.DataEnrichment do
  use Vutuv.Web, :model

  schema "data_enrichments" do
    field :user_id, :integer
    field :session_id, :integer
    field :description, :string
    field :value, :string
    field :source, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :session_id, :description, :value, :source])
    |> validate_required([:user_id, :session_id, :description, :value, :source])
  end
end

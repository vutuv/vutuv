defmodule Vutuv.TagUrl do
  use Vutuv.Web, :model

  schema "tag_urls" do
    field :value, :string
    field :name, :string
    field :description, :string

    belongs_to :tag_localization, Vutuv.TagLocalization

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :name, :description])
    |> validate_required([:value, :name])
  end
end

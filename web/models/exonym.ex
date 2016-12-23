defmodule Vutuv.Exonym do
  use Vutuv.Web, :model

  schema "exonyms" do
    field :value, :string

    belongs_to :locale, Vutuv.Locale

    has_one :exonym_locale, Vutuv.Locale

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value])
    |> validate_required([:value])
  end
end

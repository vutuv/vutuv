defmodule Vutuv.Exonym do
  use Vutuv.Web, :model

  schema "exonyms" do
    field :value, :string

    belongs_to :locale, Vutuv.Locale

    belongs_to :exonym_locale, Vutuv.Locale

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :locale_id, :exonym_locale_id])
    |> validate_required([:value, :locale_id, :exonym_locale_id])
    |> foreign_key_constraint(:locale)
    |> foreign_key_constraint(:exonym_locale)
    |> unique_constraint(:value_locale_id)
    |> validate_length(:value, max: 40)
  end
end

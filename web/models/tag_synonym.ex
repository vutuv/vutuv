defmodule Vutuv.TagSynonym do
  use Vutuv.Web, :model

  schema "tag_synonyms" do
    field :value, :string

    belongs_to :tag, Vutuv.Tag
    belongs_to :locale, Vutuv.Locale

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :locale_id])
    |> validate_required([:value, :locale_id])
    |> unique_constraint(:value_locale_id, message: "A synonym with this value and locale already exists for this tag.")
  end
end

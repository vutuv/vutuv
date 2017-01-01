defmodule Vutuv.TagSynonym do
  use Vutuv.Web, :model

  schema "tag_synonyms" do
    field :value, :string

    belongs_to :tag, Vutuv.Tag
    has_one :locale, Vutuv.Locale, on_delete: :delete_all

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

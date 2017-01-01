defmodule Vutuv.TagLocalization do
  use Vutuv.Web, :model

  schema "tag_localizations" do
    field :name, :string
    field :description, :string

    belongs_to :tag, Vutuv.Tag
    belongs_to :locale, Vutuv.Locale

    has_many :tag_urls, Vutuv.TagUrl, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :locale_id, :tag_id])
    |> validate_required([:name, :locale_id])
    |> foreign_key_constraint(:tag_id)
    |> foreign_key_constraint(:locale_id)
  end
end

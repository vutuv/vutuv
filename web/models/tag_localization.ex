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
    |> unique_constraint(:tag_id_locale_id, message: "A localization with this locale already exists for this tag.")
    |> validate_length(:name, max: 40)
    |> validate_length(:description, max: 255)
  end
end

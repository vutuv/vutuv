defmodule Vutuv.TagUrl do
  use Vutuv.Web, :model

  import Vutuv.Gettext

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
    |> unique_constraint(:tag_localization_id_value, message: "A url with this value already exists for this tag.")
    |> validate_length(:name, max: 40)
    |> validate_length(:description, max: 256)
    |> validate_url
  end

  defp validate_url(changeset) do
    url = get_change(changeset, :value)

    if url do
      uri = URI.parse(url)
      case uri do
        %URI{scheme: nil} -> add_error(changeset, :value, gettext("Invalid URL"))
        %URI{host: nil, path: nil} -> add_error(changeset, :value, gettext("Invalid URL"))
        _ ->
          case to_char_list(uri.host) |> :inet.gethostbyname do
            {:ok, _res} -> changeset
            _ -> add_error(changeset, :value, gettext("Can't find URL"))
          end
      end
    else
      changeset
    end
  end
end

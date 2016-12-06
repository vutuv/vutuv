defmodule Vutuv.Url do
  use Vutuv.Web, :model

  schema "urls" do
    field :value, :string
    field :description, :string

    belongs_to :user, Vutuv.User
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:value, :description])
    |> validate_required([:value])
    |> validate_length(:description, max: 45)
    |> ensure_http_prefix
    |> validate_url
  end

  defp validate_url(changeset) do
    url = get_change(changeset, :value)

    if url do
      uri = URI.parse(url)
      case uri do
        %URI{scheme: nil} -> add_error(changeset, :value, "invalid url")
        %URI{host: nil, path: nil} -> add_error(changeset, :value, "invalid url")
        _ ->
          case to_char_list(uri.host) |> :inet.gethostbyname do
            {:ok, _res} -> changeset
            _ -> add_error(changeset, :value, "can't resolve url")
          end
      end
    else
      changeset
    end
  end

  defp ensure_http_prefix(changeset) do
    url = get_change(changeset, :value)
    if url && !String.contains?(url,["http://", "https://"]) do
      put_change(changeset, :value, "http://#{url}")
    else
      changeset
    end
  end
end

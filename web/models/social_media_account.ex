defmodule Vutuv.SocialMediaAccount do
  use Vutuv.Web, :model

  schema "social_media_accounts" do
    field :provider, :string
    field :value, :string

    belongs_to :user, Vutuv.User
    timestamps
  end

  @required_fields ~w(provider value)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required([:provider, :value])
    |> update_change(:value, &parse_value/1)
    |> validate_change(:value, &validate_parse/2)
    |> validate_format(:value, ~r/^[a-z0-9-\.]*$/u)
  end

  def parse_value(value) do
    value
    |>String.replace(~r/^(http:\/\/)?(www\.)?\w*\.[a-z]*\/$/u,"")
    |>String.split(~r/\//, [trim: true])
    |>List.last
  end

  def validate_parse(_, value) do
    if value, do: [], else: [value: {"Invalid account name", []}]
  end

  def get_full_urls(user) do
    for account <- Vutuv.Repo.all(from s in Vutuv.SocialMediaAccount, where: s.user_id == ^user.id) do
      case (account.provider) do
        "Facebook" -> "http://facebook.com/#{account.value}"
        "Twitter" -> "http://twitter.com/#{account.value}"
        "Instagram" -> "http://instagram.com/#{account.value}"
        "Youtube" -> "http://youtube.com/channel/#{account.value}"
        "Snapchat" -> ""
        "Stackoverflow" -> "http://stackoverflow.com/users/#{account.value}"
        _ -> ""
      end
    end
  end
end

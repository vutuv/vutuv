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

  base_urls = [
    {"Facebook" , "http://facebook.com/"},
    {"Twitter" , "http://twitter.com/"},
    {"Instagram" , "http://instagram.com/"},
    {"Youtube" , "http://youtube.com/channel/"},
    {"Stackoverflow" , "http://stackoverflow.com/users/"},
    {"Snapchat" , ""}
  ]

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
    |> validate_format(:value, ~r/^@?[A-z0-9-\.]*$/u)
  end

  def parse_value(value) do
    value
    |> String.replace(~r/^(http:\/\/)?(www\.)?\w*\.[a-z]*\/$/u,"")
    |> String.replace(~r/^@?/, "")
    |> String.split(~r/\//, [trim: true])
    |> List.last
  end

  def validate_parse(_, value) do
    if value, do: [], else: [value: {"Invalid account name", []}]
  end

  for {provider, url} <- base_urls do #This generates special rule matches
    def get_full_url(%__MODULE__{provider: unquote(provider), value: value}), do: unquote(url)<>value
  end

  def get_full_url(_), do: ""
end

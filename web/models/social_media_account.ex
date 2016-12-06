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

  @accepted_providers ~w(Facebook Twitter Google+ Instagram Youtube Snapchat LinkedIn XING)

  base_urls = [
    {"Facebook" , "http://facebook.com/"},
    {"Twitter" , "http://twitter.com/"},
    {"Google+", "https://plus.google.com/+"},
    {"Instagram" , "http://instagram.com/"},
    {"Youtube" , "http://youtube.com/channel/"},
    {"Snapchat" , nil},
    {"LinkedIn", "https://www.linkedin.com/in/"},
    {"XING", "https://www.xing.com/profile/"}
  ]

  display_rules = [
    {"Facebook" , ""},
    {"Twitter" , "@"},
    {"Google+", ""},
    {"Instagram" , "@"},
    {"Youtube" , ""},
    {"Snapchat" , ""},
    {"LinkedIn", ""},
    {"XING", ""}
  ]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required([:provider, :value])
    |> unique_constraint(:value_provider, message: "Someone has already claimed this account")
    |> update_change(:value, &parse_value/1)
    |> validate_change(:value, &validate_parse/2)
    |> validate_format(:value, ~r/^@?[A-z0-9-\.]*$/u)
    |> validate_inclusion(:provider, @accepted_providers)
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

  for {provider, pretext} <- display_rules do #This generates special display rule matches
    def get_display(%__MODULE__{provider: unquote(provider), value: value}), do: unquote(pretext)<>value
  end

  def get_display(_), do: ""

  for url <- base_urls do #This generates special url rule matches
    case url do
    {provider, nil} -> def social_media_link(%__MODULE__{provider: unquote(provider), value: value}), do: value
    {provider, url} ->
      def social_media_link(%__MODULE__{provider: unquote(provider), value: value} = account) do
        Phoenix.HTML.Link.link get_display(account), to: unquote(url)<>value
      end
    end
  end

  def social_media_link(_), do: ""

  # defp unique_constraint_error(%{"value" => value}) do
  #   unique_constraint_error(%{value: value})
  # end

  # defp unique_constraint_error(%{value: value}) do
  #   #account = Vutuv.Repo.one!(from s in __MODULE__, where: s.value == ^value, preload: [:user])
  #   "Someone has already claimed this account"
  # end

  # defp unique_constraint_error(_), do: ""
end

defmodule Vutuv.SocialNetworks.SocialMediaAccount do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.UserProfiles.User

  @type t :: %__MODULE__{
          id: integer,
          provider: String.t(),
          value: String.t(),
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "social_media_accounts" do
    field :provider, :string
    field :value, :string

    belongs_to :user, User

    timestamps()
  end

  @provider_urls %{
    "Facebook" => "https://facebook.com/",
    "Twitter" => "https://twitter.com/",
    "Instagram" => "https://instagram.com/",
    "Youtube" => "https://youtube.com/channel/",
    "Snapchat" => "https://www.snapchat.com/add/",
    "LinkedIn" => "https://www.linkedin.com/in/",
    "XING" => "https://www.xing.com/profile/",
    "GitHub" => "https://github.com/"
  }
  @providers Map.keys(@provider_urls)

  @doc false
  def changeset(social_media_account, attrs) do
    social_media_account
    |> cast(attrs, [:provider, :value])
    |> validate_required([:provider, :value])
    |> unique_constraint(:value, name: :provider_value)
    |> update_change(:value, &parse_value/1)
    |> validate_change(:value, &validate_parse/2)
    |> validate_format(:value, ~r/^@?[A-z0-9-\.]*$/u)
    |> validate_inclusion(:provider, @providers)
  end

  defp parse_value(value) do
    %URI{path: path} = URI.parse(value)
    if path, do: String.trim(path, "/")
  end

  defp validate_parse(_, value) do
    if value, do: [], else: [value: {"Invalid account name", []}]
  end

  @doc """
  Returns the url and display value for the social media account.
  """
  @spec create_link(t()) :: tuple
  def create_link(%__MODULE__{provider: provider, value: value}) do
    {Map.get(@provider_urls, provider) <> value, display(provider, value)}
  end

  defp display(provider, value) when provider in ["Twitter", "Instagram"] do
    "@" <> value
  end

  defp display(_, value), do: value
end

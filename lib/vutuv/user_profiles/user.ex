defmodule Vutuv.UserProfiles.User do
  use Ecto.Schema
  use Arc.Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.UserProfiles.{Address, Locale}
  alias Vutuv.Devices.{EmailAddress, PhoneNumber}

  alias Vutuv.{
    Accounts.UserCredential,
    Biographies.WorkExperience,
    Publications.Post,
    Sessions.Session,
    SocialNetworks.SocialMediaAccount,
    Tags.Tag,
    Tags.UserTag
  }

  @type t :: %__MODULE__{
          id: integer,
          slug: String.t(),
          full_name: String.t(),
          preferred_name: String.t(),
          gender: String.t(),
          birthday: Date.t(),
          avatar: String.t(),
          headline: String.t(),
          honorific_prefix: String.t(),
          honorific_suffix: String.t(),
          locale: String.t(),
          accept_language: String.t(),
          noindex: boolean,
          addresses: [Address.t()] | %Ecto.Association.NotLoaded{},
          email_addresses: [EmailAddress.t()] | %Ecto.Association.NotLoaded{},
          phone_numbers: [PhoneNumber.t()] | %Ecto.Association.NotLoaded{},
          posts: [Post.t()] | %Ecto.Association.NotLoaded{},
          sessions: [Session.t()] | %Ecto.Association.NotLoaded{},
          social_media_accounts: [SocialMediaAccount.t()] | %Ecto.Association.NotLoaded{},
          work_experiences: [WorkExperience.t()] | %Ecto.Association.NotLoaded{},
          tags: [Tag.t()] | %Ecto.Association.NotLoaded{},
          user_credential: UserCredential.t() | %Ecto.Association.NotLoaded{},
          user_tags: [UserTag.t()] | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @derive {Phoenix.Param, key: :slug}

  schema "users" do
    field :slug, :string
    field :full_name, :string
    field :preferred_name, :string
    field :gender, :string
    field :birthday, :date
    field :avatar, Vutuv.Avatar.Type
    field :headline, :string
    field :honorific_prefix, :string
    field :honorific_suffix, :string
    field :locale, :string
    field :accept_language, :string
    field :noindex, :boolean, default: false

    has_many :addresses, Address, on_delete: :delete_all
    has_many :email_addresses, EmailAddress, on_delete: :delete_all
    has_many :phone_numbers, PhoneNumber, on_delete: :delete_all
    has_many :posts, Post, on_delete: :delete_all
    has_many :sessions, Session, on_delete: :delete_all
    has_many :social_media_accounts, SocialMediaAccount, on_delete: :delete_all
    has_many :user_tags, UserTag, on_delete: :delete_all
    has_many :work_experiences, WorkExperience, on_delete: :delete_all
    has_one :user_credential, UserCredential, on_delete: :delete_all

    many_to_many :tags, Tag, join_through: UserTag, on_replace: :delete

    many_to_many :followers, __MODULE__,
      join_through: "user_connections",
      on_replace: :delete,
      join_keys: [follower_id: :id, followee_id: :id]

    many_to_many :followees, __MODULE__,
      join_through: "user_connections",
      on_replace: :delete,
      join_keys: [followee_id: :id, follower_id: :id]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [
      :slug,
      :full_name,
      :preferred_name,
      :honorific_prefix,
      :honorific_suffix,
      :gender,
      :birthday,
      :locale,
      :headline,
      :noindex
    ])
    |> unique_constraint(:slug)
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:full_name, :gender])
    |> validate_length(:full_name, max: 80)
    |> validate_length(:preferred_name, max: 80)
    |> validate_length(:honorific_prefix, max: 80)
    |> validate_length(:honorific_suffix, max: 80)
    |> validate_length(:headline, max: 255)
    |> add_locale_data()
  end

  @doc false
  def create_changeset(%__MODULE__{} = user, attrs) do
    {attrs, al} =
      case Map.get(attrs, "accept_language") do
        nil -> {attrs, nil}
        al -> {Map.put(attrs, "locale", Locale.parse_al(al)), al}
      end

    user
    |> cast(attrs, [:full_name, :gender, :locale, :noindex])
    |> validate_required([:full_name, :gender])
    |> validate_length(:full_name, max: 80)
    |> change(%{accept_language: al})
    |> add_locale_data()
    |> cast_assoc(:email_addresses, required: true)
    |> cast_assoc(:user_credential, required: true)
  end

  @doc """
  Changeset for adding and updating user_tags.
  """
  def user_tag_changeset(%__MODULE__{} = user, tags) do
    user
    |> cast(%{}, [])
    |> put_assoc(:tags, tags)
  end

  def followee_changeset(%__MODULE__{} = user, followees) do
    user
    |> cast(%{}, [])
    |> put_assoc(:followees, followees)
  end

  defp add_locale_data(%Ecto.Changeset{valid?: true, changes: %{locale: locale}} = changeset) do
    case Locale.supported(locale) do
      nil -> add_error(changeset, :locale, "Unsupported locale")
      new_locale -> change(changeset, %{locale: new_locale})
    end
  end

  defp add_locale_data(changeset), do: changeset
end

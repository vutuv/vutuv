defmodule Vutuv.Biographies.Profile do
  use Ecto.Schema
  use Arc.Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.Accounts.User
  alias Vutuv.Biographies.{Locale, PhoneNumber}
  alias Vutuv.Generals.Tag

  @type t :: %__MODULE__{
          id: integer,
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
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
          noindex?: boolean,
          phone_numbers: [PhoneNumber.t()] | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "profiles" do
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
    field :noindex?, :boolean, default: false

    belongs_to :user, User
    has_many :phone_numbers, PhoneNumber, on_delete: :delete_all

    many_to_many :tags, Tag, join_through: "profile_tags", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = profile, attrs) do
    profile
    |> cast(attrs, [
      :full_name,
      :preferred_name,
      :honorific_prefix,
      :honorific_suffix,
      :gender,
      :birthday,
      :locale,
      :headline,
      :noindex?
    ])
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
  def create_changeset(%__MODULE__{} = profile, attrs) do
    {attrs, al} =
      case Map.get(attrs, "accept_language") do
        nil -> {attrs, nil}
        al -> {Map.put(attrs, "locale", Locale.parse_al(al)), al}
      end

    profile
    |> changeset(attrs)
    |> change(%{accept_language: al})
  end

  defp add_locale_data(%Ecto.Changeset{valid?: true, changes: %{locale: locale}} = changeset) do
    case Locale.supported(locale) do
      nil -> add_error(changeset, :locale, "Unsupported locale")
      new_locale -> change(changeset, %{locale: new_locale})
    end
  end

  defp add_locale_data(changeset), do: changeset
end

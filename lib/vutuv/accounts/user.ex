defmodule Vutuv.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias NotQwerty123.PasswordStrength
  alias Vutuv.Accounts.EmailAddress
  alias Vutuv.{Biographies.Profile, Sessions.Session, Socials.Post}

  @type t :: %__MODULE__{
          id: integer,
          slug: String.t(),
          password_hash: String.t(),
          otp_secret: String.t(),
          confirmed: boolean,
          email_addresses: [EmailAddress.t()] | %Ecto.Association.NotLoaded{},
          posts: [Post.t()] | %Ecto.Association.NotLoaded{},
          sessions: [Session.t()] | %Ecto.Association.NotLoaded{},
          profile: Profile.t() | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @derive {Phoenix.Param, key: :slug}

  schema "users" do
    field :slug, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :otp_secret, :string
    field :confirmed, :boolean, default: false

    has_many :email_addresses, EmailAddress, on_delete: :delete_all
    has_many :posts, Post, on_delete: :delete_all
    has_many :sessions, Session, on_delete: :delete_all
    has_one :profile, Profile, on_replace: :update, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:slug])
    |> unique_constraint(:slug)
  end

  def create_changeset(%__MODULE__{} = user, attrs) do
    user
    |> Map.put(:otp_secret, OneTimePassEcto.Base.gen_secret())
    |> password_hash_changeset(attrs)
    |> cast_assoc(:email_addresses, required: true)
    |> cast_assoc(:profile, required: true, with: &Profile.create_changeset/2)
  end

  def update_changeset(%__MODULE__{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast_assoc(:profile)
  end

  def confirm_changeset(%__MODULE__{} = user, confirmed) do
    change(user, %{confirmed: confirmed})
  end

  def update_password_changeset(%__MODULE__{} = user, attrs) do
    password_hash_changeset(user, attrs)
  end

  defp password_hash_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_password(:password)
    |> put_pass_hash()
  end

  defp validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case PasswordStrength.strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset
end

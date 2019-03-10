defmodule Vutuv.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.Sessions.Session 
  alias Vutuv.Accounts.EmailAddress
  alias Vutuv.Accounts.Role
  alias Vutuv.Biographies.Profile

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :confirmed_at, :utc_datetime
    field :reset_sent_at, :utc_datetime

    has_many :sessions, Session, on_delete: :delete_all
    has_one :profiles, Profile, foreign_key: :user_id, on_delete: :delete_all
    has_many :email_addresses, EmailAddress, on_delete: :delete_all
    many_to_many :roles, Role, on_delete: :delete_all, join_through: "user_roles"

    timestamps()
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_email
  end

  def create_changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_email
    |> validate_password(:password)
    |> put_pass_hash
    |> cast_assoc(:sessions)
    |> cast_assoc(:profiles)
    |> cast_assoc(:email_addresses)
    |> cast_assoc(:roles)
  end

  def confirm_changeset(user) do
    change(user, %{confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)})
  end

  def password_reset_changeset(user, reset_sent_at) do
    change(user, %{reset_sent_at: reset_sent_at})
  end

  defp unique_email(changeset) do
    validate_format(changeset, :email, ~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/)
    |> validate_length(:email, max: 80)
    |> unique_constraint(:email, downcase: true)
  end

  # In the function below, strong_password? just checks that the password
  # is at least 8 characters long.
  # See the documentation for NotQwerty123.PasswordStrength.strong_password?
  # for a more comprehensive password strength checker.
  defp validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  # If you are using Bcrypt or Pbkdf2, change Argon2 to Bcrypt or Pbkdf2
  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
      %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  defp strong_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end

  defp strong_password?(_), do: {:error, "The password is too short"}
end

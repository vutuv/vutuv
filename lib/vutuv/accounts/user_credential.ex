defmodule Vutuv.Accounts.UserCredential do
  use Ecto.Schema

  import Ecto.Changeset

  alias NotQwerty123.PasswordStrength
  alias Vutuv.UserProfiles.User

  @type t :: %__MODULE__{
          id: integer,
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
          password_hash: String.t(),
          otp_secret: String.t(),
          confirmed: boolean,
          is_admin: boolean,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "user_credentials" do
    field :password, :string, virtual: true
    field :password_hash, :string
    field :otp_secret, :string
    field :confirmed, :boolean, default: false
    field :is_admin, :boolean, default: false

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = user_credential, attrs) do
    user_credential
    |> Map.put(:otp_secret, OneTimePassEcto.Base.gen_secret())
    |> cast(attrs, [:otp_secret, :password])
    |> validate_required([:otp_secret, :password])
    |> validate_password(:password)
    |> put_pass_hash()
  end

  def confirm_changeset(%__MODULE__{} = user_credential, confirmed) do
    change(user_credential, %{confirmed: confirmed})
  end

  def update_password_changeset(%__MODULE__{} = user_credential, attrs) do
    user_credential
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

  def admin_changeset(user_credential, attrs) do
    cast(user_credential, attrs, [:is_admin])
  end
end

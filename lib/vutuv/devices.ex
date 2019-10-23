defmodule Vutuv.Devices do
  @moduledoc """
  Devices context.
  """

  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.{UserProfiles.User, Repo}
  alias Vutuv.Devices.{EmailAddress, PhoneNumber}

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns a list of unverified email addresses.

  This is used by the EmailManager, which is responsible for handling
  unverified email addresses.
  """
  @spec list_unverified_email_addresses(integer) :: [EmailAddress.t()]
  def list_unverified_email_addresses(max_age) do
    inserted_at = DateTime.add(DateTime.utc_now(), -max_age)

    EmailAddress
    |> where([e], e.verified == false and e.inserted_at < ^inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets an unverified email address. Raises error if not found.
  """
  @spec get_unverified_email_address!(map) :: EmailAddress.t() | no_return
  def get_unverified_email_address!(%{"value" => value}) do
    Repo.get_by!(EmailAddress, value: value, verified: false)
  end

  @doc """
  Returns a list of a user's email_addresses.
  """
  @spec list_email_addresses(User.t()) :: [EmailAddress.t()]
  def list_email_addresses(%User{} = user) do
    Repo.all(assoc(user, :email_addresses))
  end

  @doc """
  Returns a list of a user's public email_addresses.
  """
  @spec list_email_addresses(User.t(), :public) :: [EmailAddress.t()]
  def list_email_addresses(user, :public) do
    user
    |> assoc(:email_addresses)
    |> where([e], e.is_public == true)
    |> Repo.all()
  end

  @doc """
  Gets an email_address from the email_address value.

  Only public email_addresses are returned. Returns nil if no email_address found.
  """
  @spec get_email_address(map) :: EmailAddress.t() | nil
  def get_email_address(%{"value" => value}) do
    Repo.get_by(EmailAddress, value: value, is_public: true)
  end

  @doc """
  Gets a specific user's email_address. Raises error if no email_address found.
  """
  @spec get_email_address!(User.t(), integer) :: EmailAddress.t() | no_return
  def get_email_address!(%User{} = user, id) do
    Repo.get_by!(EmailAddress, id: id, user_id: user.id)
  end

  @doc """
  Creates an email_address.
  """
  @spec create_email_address(User.t(), map) :: {:ok, EmailAddress.t()} | changeset_error
  def create_email_address(%User{} = user, attrs \\ %{}) do
    query = from e in EmailAddress, where: e.user_id == ^user.id
    email_count = Repo.aggregate(query, :count, :id)
    attrs = Map.put(attrs, "position", email_count + 1)

    user
    |> build_assoc(:email_addresses)
    |> EmailAddress.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an email_address.
  """
  @spec update_email_address(EmailAddress.t(), map) :: {:ok, EmailAddress.t()} | changeset_error
  def update_email_address(%EmailAddress{} = email_address, attrs) do
    email_address
    |> EmailAddress.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Verifies an email_address, setting the verified value to true.
  """
  @spec verify_email_address(EmailAddress.t()) :: {:ok, EmailAddress.t()} | changeset_error
  def verify_email_address(email_address) do
    email_address |> EmailAddress.verify_changeset() |> Repo.update()
  end

  @doc """
  Deletes an email_address.
  """
  @spec delete_email_address(EmailAddress.t()) :: {:ok, EmailAddress.t()} | changeset_error
  def delete_email_address(%EmailAddress{} = email_address) do
    Repo.delete(email_address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking email_address changes.
  """
  @spec change_email_address(EmailAddress.t()) :: Ecto.Changeset.t()
  def change_email_address(%EmailAddress{} = email_address) do
    EmailAddress.changeset(email_address, %{})
  end

  def duplicate_email_error?(%Ecto.Changeset{changes: %{email_addresses: [email_address]}}) do
    Enum.any?(email_address.errors, fn {_, {msg, _}} -> msg == "duplicate" end)
  end

  def duplicate_email_error?(%Ecto.Changeset{errors: errors}) do
    Enum.any?(errors, fn {_, {msg, _}} -> msg == "duplicate" end)
  end

  def duplicate_email_error?(_), do: false

  @doc """
  Returns the list of phone_numbers.
  """
  @spec list_phone_numbers(User.t()) :: [PhoneNumber.t()]
  def list_phone_numbers(%User{} = user) do
    Repo.all(assoc(user, :phone_number))
  end

  @doc """
  Gets a single phone_number. Raises error if no phone_number found.
  """
  @spec get_phone_number!(User.t(), integer) :: PhoneNumber.t() | no_return
  def get_phone_number!(%User{} = user, id) do
    Repo.get_by!(PhoneNumber, id: id, user_id: user.id)
  end

  @doc """
  Creates a phone_number.
  """
  @spec create_phone_number(User.t(), map) :: {:ok, PhoneNumber.t()} | changeset_error
  def create_phone_number(%User{} = user, attrs \\ %{}) do
    user
    |> build_assoc(:phone_numbers)
    |> PhoneNumber.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a phone_number.
  """
  @spec update_phone_number(PhoneNumber.t(), map) :: {:ok, PhoneNumber.t()} | changeset_error
  def update_phone_number(%PhoneNumber{} = phone_number, attrs) do
    phone_number
    |> PhoneNumber.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PhoneNumber.
  """
  @spec delete_phone_number(PhoneNumber.t()) :: {:ok, PhoneNumber.t()} | changeset_error
  def delete_phone_number(%PhoneNumber{} = phone_number) do
    Repo.delete(phone_number)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking phone_number changes.
  """
  @spec change_phone_number(PhoneNumber.t()) :: Ecto.Changeset.t()
  def change_phone_number(%PhoneNumber{} = phone_number) do
    PhoneNumber.changeset(phone_number, %{})
  end
end

defmodule Vutuv.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.{Repo, Sessions, Sessions.Session}
  alias Vutuv.Accounts.{EmailAddress, User}

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns the list of users.
  """
  @spec list_users() :: [User.t()]
  def list_users() do
    User
    |> join(:left, [u], _ in assoc(u, :email_addresses))
    |> join(:left, [u], _ in assoc(u, :profile))
    |> preload([_, e, p], email_addresses: e, profile: p)
    |> Repo.all()
  end

  @doc """
  Gets a single user.
  """
  @spec get_user(integer) :: User.t() | nil
  def get_user(id) do
    User
    |> where([u], u.id == ^id)
    |> join(:left, [u], _ in assoc(u, :email_addresses))
    |> join(:left, [u], _ in assoc(u, :profile))
    |> preload([_, e, p], email_addresses: e, profile: p)
    |> Repo.one()
  end

  @doc """
  Gets a user based on the params.

  This is used by Phauxth to get user information.
  """
  @spec get_by(map) :: User.t() | nil
  def get_by(%{"session_id" => session_id}) do
    with %Session{user_id: user_id} <- Sessions.get_session(session_id),
         do: get_user(user_id)
  end

  def get_by(%{"email" => email}) do
    case Repo.get_by(EmailAddress, %{value: email}) do
      %EmailAddress{user_id: user_id} -> get_user(user_id)
      _ -> nil
    end
  end

  def get_by(%{"user_id" => user_id}), do: Repo.get(User, user_id)

  @doc """
  Creates a user.
  """
  @spec create_user(map) :: {:ok, User.t()} | changeset_error
  def create_user(attrs) do
    email_attrs = %{
      "value" => attrs["email"],
      "position" => 1,
      "description" => "email when registering vutuv"
    }

    profile_attrs = %{
      "gender" => attrs["gender"],
      "first_name" => attrs["first_name"],
      "last_name" => attrs["last_name"]
    }

    attrs = Map.merge(attrs, %{"email_addresses" => [email_attrs], "profile" => profile_attrs})

    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  @spec update_user(User.t(), map) :: {:ok, User.t()} | changeset_error
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  @spec delete_user(User.t()) :: {:ok, User.t()} | changeset_error
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  @spec change_user(User.t()) :: Ecto.Changeset.t()
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Confirms a user's email.

  This function sets the user's confirmed_at value, and the email_address's
  verified value, to true.
  """
  @spec confirm_user_email(User.t()) :: {:ok, User.t()} | changeset_error
  def confirm_user_email(%User{confirmed_at: nil} = user) do
    user |> User.confirm_changeset() |> Repo.update()
    confirm_email(user)
  end

  def confirm_user_email(user), do: confirm_email(user)

  defp confirm_email(%User{current_email: email, email_addresses: email_addresses}) do
    email_addresses
    |> Enum.find(&(&1.value == email))
    |> EmailAddress.verify_changeset()
    |> Repo.update()
  end

  @doc """
  Makes a password reset request.
  """
  @spec create_password_reset(map) :: {:ok, User.t()} | nil
  def create_password_reset(attrs) do
    with %User{} = user <- get_by(attrs) do
      user
      |> User.password_reset_changeset(DateTime.utc_now() |> DateTime.truncate(:second))
      |> Repo.update()
    end
  end

  @doc """
  Updates a user's password.
  """
  @spec update_password(User.t(), map) :: {:ok, User.t()} | changeset_error
  def update_password(%User{} = user, attrs) do
    Sessions.delete_user_sessions(user)

    user
    |> User.update_password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns the list of a user's email_addresses.
  """
  @spec list_email_addresses(User.t()) :: [EmailAddress.t()]
  def list_email_addresses(user) do
    Repo.all(assoc(user, :email_addresses))
  end

  @doc """
  Gets a single email_address.
  """
  @spec get_email_address(integer) :: EmailAddress.t() | nil
  def get_email_address(id), do: Repo.get(EmailAddress, id)

  @doc """
  Creates an email_address.
  """
  @spec create_email_address(User.t(), map) :: {:ok, EmailAddress.t()} | changeset_error
  def create_email_address(%User{} = user, attrs \\ %{}) do
    email_count = length(user.email_addresses)
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
    |> EmailAddress.changeset(attrs)
    |> Repo.update()
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
end

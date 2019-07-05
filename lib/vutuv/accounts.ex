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
    |> user_query()
    |> Repo.all()
  end

  @doc """
  Gets a single user.
  """
  @spec get_user(integer) :: User.t() | nil
  def get_user(id) do
    User
    |> where([u], u.id == ^id)
    |> user_query()
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
    with %EmailAddress{user_id: user_id} <- Repo.get_by(EmailAddress, %{value: email}),
         do: get_user(user_id)
  end

  def get_by(%{"slug" => slug}) do
    User
    |> where([u], u.slug == ^slug)
    |> user_query()
    |> Repo.one()
  end

  def get_by(%{"user_id" => user_id}), do: Repo.get(User, user_id)

  defp user_query(user) do
    user
    |> join(:inner, [u], e in assoc(u, :email_addresses))
    |> join(:inner, [u, e], p in assoc(u, :profile))
    |> preload([_, e, p], email_addresses: e, profile: p)
  end

  @doc """
  Gets user credentials.
  """
  @spec get_user_credentials(integer) :: User.t()
  def get_user_credentials(id) do
    Repo.get(User, id)
  end

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

    attrs = Map.merge(attrs, %{"email_addresses" => [email_attrs]})

    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
    |> add_unique_slug()
  end

  defp add_unique_slug({:ok, %{profile: %{full_name: full_name}} = user}) do
    slug = Slugger.slugify(full_name, ?.)

    with {:error, _} <- update_user(user, %{"slug" => slug}) do
      prefix = Base.encode64(:crypto.strong_rand_bytes(6))
      update_user(user, %{"slug" => prefix <> "." <> slug})
    end
  end

  defp add_unique_slug({:error, changeset}), do: {:error, changeset}

  @doc """
  Updates a user.
  """
  @spec update_user(User.t(), map) :: {:ok, User.t()} | changeset_error
  def update_user(%User{} = user, attrs) do
    user |> User.update_changeset(attrs) |> Repo.update()
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
  Confirms a user's account, setting the user's confirmed value.
  """
  @spec confirm_user(User.t()) :: {:ok, User.t()} | changeset_error
  def confirm_user(user) do
    user |> User.confirm_changeset(true) |> Repo.update()
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
  Returns a list of unconfirmed email addresses.
  """
  @spec unverified_email_addresses(integer) :: [EmailAddress.t()]
  def unverified_email_addresses(max_age) do
    inserted_at = DateTime.add(DateTime.utc_now(), -max_age)

    EmailAddress
    |> where([e], e.verified == false and e.inserted_at < ^inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns a list of a user's email_addresses.
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
  Gets a user's email_address.
  """
  @spec get_user_email_address(User.t(), integer) :: EmailAddress.t() | nil
  def get_user_email_address(%User{id: user_id}, id) do
    EmailAddress
    |> where([e], e.id == ^id and e.user_id == ^user_id)
    |> Repo.one()
  end

  @doc """
  Gets an email_address using the email value.
  """
  @spec get_email_address_from_value(String.t()) :: EmailAddress.t() | nil
  def get_email_address_from_value(email) do
    Repo.get_by(EmailAddress, %{value: email})
  end

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
    |> EmailAddress.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Confirms an email_address, setting the verified value to true.
  """
  @spec confirm_email_address(EmailAddress.t()) :: {:ok, EmailAddress.t()} | changeset_error
  def confirm_email_address(email_address) do
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
end

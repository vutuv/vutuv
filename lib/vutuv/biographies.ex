defmodule Vutuv.Biographies do
  @moduledoc """
  The Biographies context.
  """
  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.Repo

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  alias Vutuv.{Biographies.Profile}

  @doc """
  Returns the list of profiles.
  """
  @spec list_profiles() :: [Profile.t()]
  def list_profiles do
    Repo.all(Profile)
  end

  @doc """
  Gets a single profile.
  """
  @spec get_profile(integer) :: Profile.t() | nil
  def get_profile(id), do: Repo.get(Profile, id)

  @spec get_profile_user(integer) :: Profile.t() | nil
  def get_profile_user(user_id) do
    query =
      from p in Profile,
        where: p.user_id == ^user_id

    Repo.one(query)
  end

  @doc """
  Creates a profile.
  """
  @spec create_profile(map) :: {:ok, Profile.t()} | changeset_error
  def create_profile(attrs \\ %{}) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a profile.
  """
  @spec update_profile(Profile.t(), map) :: {:ok, Profile.t()} | changeset_error
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Profile.
  """
  @spec delete_profile(Profile.t()) :: {:ok, Profile.t()} | changeset_error
  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.
  """
  @spec change_profile(Profile.t()) :: Ecto.Changeset.t()
  def change_profile(%Profile{} = profile) do
    Profile.changeset(profile, %{})
  end

  alias Vutuv.Biographies.PhoneNumber

  @doc """
  Returns the list of phone_numbers.

  ## Examples

      iex> list_phone_numbers()
      [%PhoneNumber{}, ...]

  """
  @spec list_phone_numbers(Profile.t()) :: [PhoneNumber.t()]
  def list_phone_numbers(profile) do
    Repo.all(assoc(profile, :phone_number))
  end

  @doc """
  Gets a single phone_number.
  """
  @spec get_phone_number(integer) :: PhoneNumber.t() | nil
  def get_phone_number(id), do: Repo.get(PhoneNumber, id)

  @doc """
  Creates a phone_number.
  """
  @spec create_phone_number(Profile.t(), map) :: {:ok, PhoneNumber.t()} | changeset_error
  def create_phone_number(%Profile{} = profile, attrs \\ %{}) do
    profile
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

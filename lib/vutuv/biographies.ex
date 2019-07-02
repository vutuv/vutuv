defmodule Vutuv.Biographies do
  @moduledoc """
  The Biographies context.
  """

  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.Repo

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  alias Vutuv.Biographies.{Profile, PhoneNumber, ProfileTag}
  alias Vutuv.Generals.Tag

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

  @doc """
  Gets a single profile with phone numbers and tags.
  """
  @spec get_profile_complete(integer) :: Profile.t() | nil
  def get_profile_complete(user_id) do
    Profile
    |> where([p], p.id == ^user_id)
    |> join(:left, [p], _ in assoc(p, :phone_numbers))
    |> join(:left, [p], _ in assoc(p, :tags))
    |> preload([_, pn, t], phone_numbers: pn, tags: t)
    |> Repo.one()
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

  @doc """
  Returns the list of phone_numbers.
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

  @doc """
  List of tags of a profile.
  """
  @spec list_profile_tags(Profile.t()) :: [Tag.t()]
  def list_profile_tags(profile) do
    Repo.all(assoc(profile, :tags))
  end

  @doc """
  Gets a single ProfileTag.
  """
  @spec get_profile_tag(integer, integer) :: ProfileTag.t() | nil
  def get_profile_tag(profile_id, tag_id) do
    query =
      from pt in ProfileTag,
        where: pt.profile_id == ^profile_id and pt.tag_id == ^tag_id

    Repo.one(query)
  end

  @doc """
  Add a ProfileTag.
  """
  @spec add_profile_tags(Profile.t(), Tag.t()) :: {:ok, ProfileTag.t()} | changeset_error
  def add_profile_tags(%Profile{} = profile, %Tag{} = tag) do
    add_profile_tags(profile.id, tag.id)
  end

  @spec add_profile_tags(integer, integer) :: {:ok, ProfileTag.t()} | changeset_error
  def add_profile_tags(profile_id, tag_id) do
    ProfileTag.changeset(%ProfileTag{}, %{profile_id: profile_id, tag_id: tag_id})
    |> Repo.insert()
  end

  @doc """
  Deletes a ProfileTag.
  """
  @spec remove_profile_tags(ProfileTag.t()) :: {:ok, ProfileTag.t()} | changeset_error
  def remove_profile_tags(%ProfileTag{} = profile_tag) do
    remove_profile_tags(profile_tag.profile_id, profile_tag.tag_id)
  end

  @spec remove_profile_tags(integer, integer) :: {:ok, ProfileTag.t()} | changeset_error
  def remove_profile_tags(profile_id, tag_id) do
    query = from(pt in ProfileTag, where: pt.profile_id == ^profile_id and pt.tag_id == ^tag_id)

    case Repo.delete_all(query) do
      {1, nil} -> {:ok, %ProfileTag{}}
      {0, nil} -> {:error, %Ecto.Changeset{}}
    end
  end
end

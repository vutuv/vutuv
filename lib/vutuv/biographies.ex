defmodule Vutuv.Biographies do
  @moduledoc """
  The Biographies context.
  """

  import Ecto.Query, warn: false

  alias Vutuv.Repo

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  alias Vutuv.{Biographies.Profile}

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  @spec list_profiles() :: [Profile.t()]
  def list_profiles do
    Repo.all(Profile)
  end

  @doc """
  Gets a single profile.

  ## Examples

      iex> get_profile(123)
      %Profile{}

      iex> get_profile(456)
      nil

  """
  @spec get_profile(integer) :: Profile.t() | nil
  def get_profile(id), do: Repo.get(Profile, id)

  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(%{field: value})
      {:ok, %Profile{}}

      iex> create_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_profile(map) :: {:ok, Profile.t()} | changeset_error
  def create_profile(attrs \\ %{}) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_profile(Profile.t(), map) :: {:ok, Profile.t()} | changeset_error
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Profile.

  ## Examples

      iex> delete_profile(profile)
      {:ok, %Profile{}}

      iex> delete_profile(profile)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_profile(Profile.t()) :: {:ok, Profile.t()} | changeset_error
  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{source: %Profile{}}

  """
  @spec change_profile(Profile.t()) :: Ecto.Changeset.t()
  def change_profile(%Profile{} = profile) do
    Profile.changeset(profile, %{})
  end
end

defmodule Vutuv.Biographies do
  @moduledoc """
  The Biographies context.
  """

  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.{Biographies.WorkExperience, Repo, UserProfiles.User}

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns the list of work_experiences.
  """
  @spec list_work_experiences(User.t()) :: [WorkExperience.t()]
  def list_work_experiences(%User{} = user) do
    Repo.all(assoc(user, :work_experiences))
  end

  @doc """
  Gets a single work_experience.

  Raises `Ecto.NoResultsError` if the Work experience does not exist.
  """
  @spec get_work_experience!(User.t(), integer) :: WorkExperience.t() | no_return
  def get_work_experience!(%User{} = user, id) do
    Repo.get_by!(WorkExperience, id: id, user_id: user.id)
  end

  @doc """
  Creates a work_experience.
  """
  @spec create_work_experience(User.t(), map) :: {:ok, WorkExperience.t()} | changeset_error
  def create_work_experience(%User{} = user, attrs \\ %{}) do
    user
    |> build_assoc(:work_experiences)
    |> WorkExperience.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a work_experience.
  """
  @spec update_work_experience(WorkExperience.t(), map) ::
          {:ok, WorkExperience.t()} | changeset_error
  def update_work_experience(%WorkExperience{} = work_experience, attrs) do
    work_experience
    |> WorkExperience.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a WorkExperience.
  """
  @spec delete_work_experience(WorkExperience.t()) :: {:ok, WorkExperience.t()} | changeset_error
  def delete_work_experience(%WorkExperience{} = work_experience) do
    Repo.delete(work_experience)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking work_experience changes.
  """
  @spec change_work_experience(WorkExperience.t()) :: Ecto.Changeset.t()
  def change_work_experience(%WorkExperience{} = work_experience) do
    WorkExperience.changeset(work_experience, %{})
  end
end

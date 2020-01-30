defmodule Vutuv.SocialNetworks do
  @moduledoc """
  The SocialNetworks context.
  """

  import Ecto
  import Ecto.Query, warn: false

  alias Vutuv.{SocialNetworks.SocialMediaAccount, Repo, UserProfiles.User}

  @type changeset_error :: {:error, Ecto.Changeset.t()}

  @doc """
  Returns the list of social_media_accounts.
  """
  @spec list_social_media_accounts(User.t()) :: [SocialMediaAccount.t()]
  def list_social_media_accounts(%User{} = user) do
    Repo.all(assoc(user, :social_media_accounts))
  end

  @doc """
  Gets a single social_media_account.

  Raises `Ecto.NoResultsError` if the Social media account does not exist.
  """
  @spec get_social_media_account!(User.t(), integer) :: SocialMediaAccount.t()
  def get_social_media_account!(%User{} = user, id) do
    Repo.get_by!(SocialMediaAccount, id: id, user_id: user.id)
  end

  @doc """
  Creates a social_media_account.
  """
  @spec create_social_media_account(User.t(), map) ::
          {:ok, SocialMediaAccount.t()} | changeset_error
  def create_social_media_account(%User{} = user, attrs \\ %{}) do
    user
    |> build_assoc(:social_media_accounts)
    |> SocialMediaAccount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a social_media_account.
  """
  @spec update_social_media_account(SocialMediaAccount.t(), map) ::
          {:ok, SocialMediaAccount.t()} | changeset_error
  def update_social_media_account(%SocialMediaAccount{} = social_media_account, attrs) do
    social_media_account
    |> SocialMediaAccount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SocialMediaAccount.
  """
  @spec delete_social_media_account(SocialMediaAccount.t()) ::
          {:ok, SocialMediaAccount.t()} | changeset_error
  def delete_social_media_account(%SocialMediaAccount{} = social_media_account) do
    Repo.delete(social_media_account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking social_media_account changes.
  """
  @spec change_social_media_account(SocialMediaAccount.t()) :: Ecto.Changeset.t()
  def change_social_media_account(%SocialMediaAccount{} = social_media_account) do
    SocialMediaAccount.changeset(social_media_account, %{})
  end

  @doc """
  Returns the url and display value for the social media account.
  """
  @spec social_media_link(SocialMediaAccount.t()) :: tuple
  def social_media_link(%SocialMediaAccount{} = social_media_account) do
    SocialMediaAccount.create_link(social_media_account)
  end
end

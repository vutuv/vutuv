
  alias <%= inspect schema.module %>

  @doc """
  Returns the list of <%= schema.plural %>.
  """
  @spec list_<%= schema.plural %>() :: [<%= inspect schema.alias %>.t()]
  def list_<%= schema.plural %> do
    Repo.all(<%= inspect schema.alias %>)
  end

  @doc """
  Gets a single <%= schema.singular %>.

  Raises `Ecto.NoResultsError` if the <%= schema.human_singular %> does not exist.
  """
  @spec get_<%= schema.singular %>!(integer) :: <%= inspect schema.alias %>.t() | no_return
  def get_<%= schema.singular %>!(id), do: Repo.get!(<%= inspect schema.alias %>, id)

  @doc """
  Creates a <%= schema.singular %>.
  """
  @spec create_<%= schema.singular %>(map) :: {:ok, <%= inspect schema.alias %>.t()} | changeset_error
  def create_<%= schema.singular %>(attrs \\ %{}) do
    %<%= inspect schema.alias %>{}
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a <%= schema.singular %>.
  """
  @spec update_<%= schema.singular %>(<%= inspect schema.alias %>.t(), map) :: {:ok, <%= inspect schema.alias %>.t()} | changeset_error
  def update_<%= schema.singular %>(%<%= inspect schema.alias %>{} = <%= schema.singular %>, attrs) do
    <%= schema.singular %>
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a <%= inspect schema.alias %>.
  """
  @spec delete_<%= schema.singular %>(<%= inspect schema.alias %>.t()) :: {:ok, <%= inspect schema.alias %>.t()} | changeset_error
  def delete_<%= schema.singular %>(%<%= inspect schema.alias %>{} = <%= schema.singular %>) do
    Repo.delete(<%= schema.singular %>)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking <%= schema.singular %> changes.
  """
  @spec change_<%= schema.singular %>(<%= inspect schema.alias %>.t()) :: Ecto.Changeset.t()
  def change_<%= schema.singular %>(%<%= inspect schema.alias %>{} = <%= schema.singular %>) do
    <%= inspect schema.alias %>.changeset(<%= schema.singular %>, %{})
  end

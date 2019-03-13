
  alias <%= inspect schema.module %>

  @doc """
  Returns the list of <%= schema.plural %>.

  ## Examples

      iex> list_<%= schema.plural %>()
      [%<%= inspect schema.alias %>{}, ...]

  """
  @spec list_<%= schema.plural %>() :: [<%= inspect schema.alias %>.t()]
  def list_<%= schema.plural %> do
    Repo.all(<%= inspect schema.alias %>)
  end

  @doc """
  Gets a single <%= schema.singular %>.

  ## Examples

      iex> get_<%= schema.singular %>(123)
      %<%= inspect schema.alias %>{}

      iex> get_<%= schema.singular %>(456)
      nil

  """
  @spec get_<%= schema.singular %>(id) :: <%= inspect schema.alias %>.t() | nil
  def get_<%= schema.singular %>(id), do: Repo.get(<%= inspect schema.alias %>, id)

  @doc """
  Creates a <%= schema.singular %>.

  ## Examples

      iex> create_<%= schema.singular %>(%{field: value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> create_<%= schema.singular %>(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_<%= schema.singular %>(attrs \\ %{}) :: {:ok, <%= inspect schema.alias %>.t()} | changeset_error
  def create_<%= schema.singular %>(attrs \\ %{}) do
    %<%= inspect schema.alias %>{}
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a <%= schema.singular %>.

  ## Examples

      iex> update_<%= schema.singular %>(<%= schema.singular %>, %{field: new_value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> update_<%= schema.singular %>(<%= schema.singular %>, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_<%= schema.singular %>(%<%= inspect schema.alias %>.t(), map) :: {:ok, <%= inspect schema.alias %>.t()} | changeset_error
  def update_<%= schema.singular %>(%<%= inspect schema.alias %>{} = <%= schema.singular %>, attrs) do
    <%= schema.singular %>
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a <%= inspect schema.alias %>.

  ## Examples

      iex> delete_<%= schema.singular %>(<%= schema.singular %>)
      {:ok, %<%= inspect schema.alias %>{}}

      iex> delete_<%= schema.singular %>(<%= schema.singular %>)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_<%= schema.singular %>(%<%= inspect schema.alias %>.t()) :: {:ok, <%= inspect schema.alias %>.t()} | changeset_error
  def delete_<%= schema.singular %>(%<%= inspect schema.alias %>{} = <%= schema.singular %>) do
    Repo.delete(<%= schema.singular %>)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking <%= schema.singular %> changes.

  ## Examples

      iex> change_<%= schema.singular %>(<%= schema.singular %>)
      %Ecto.Changeset{source: %<%= inspect schema.alias %>{}}

  """
  @spec change_<%= schema.singular %>(%<%= inspect schema.alias %>.t()) :: Ecto.Changeset.t()
  def change_<%= schema.singular %>(%<%= inspect schema.alias %>{} = <%= schema.singular %>) do
    <%= inspect schema.alias %>.changeset(<%= schema.singular %>, %{})
  end

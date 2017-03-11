defmodule Vutuv.FullcontactCache do
  use Vutuv.Web, :model

  schema "fullcontact_caches" do
    field :email_address, :string
    field :content, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email_address, :content])
    |> validate_required([:email_address, :content])
  end
end

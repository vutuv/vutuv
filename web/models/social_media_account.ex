defmodule Vutuv.SocialMediaAccount do
  use Vutuv.Web, :model

  schema "social_media_accounts" do
    field :provider, :string
    field :account, :string

    belongs_to :user, Vutuv.User
    timestamps
  end

  @required_fields ~w(provider account)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required([:provider, :account])
    |> update_change(:account, &parse_account/1)
    |> validate_change(:account, &validate_parse/2)
    |> validate_format(:account, ~r/^[a-z0-9-\.]*$/u)
  end

  def parse_account(account) do
    account
    |>String.replace(~r/^(http:\/\/)?(www\.)?\w*\.[a-z]*\/$/u,"")
    |>String.split(~r/\//, [trim: true])
    |>List.last
  end

  def validate_parse(_, account) do
    if account, do: [], else: [account: {"Invalid account", []}]
  end

end

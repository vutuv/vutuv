defmodule VutuvWeb.Auth.Login do
  @moduledoc """
  Custom login module that checks if the user is confirmed before
  allowing the user to log in.
  """

  use Phauxth.Login.Base

  alias Vutuv.{Accounts, UserProfiles}

  @impl true
  def authenticate(%{"password" => password} = params, _, opts) do
    case Accounts.get_user_credential(params) do
      nil -> {:error, "no user found"}
      %{confirmed: false} -> {:error, "account unconfirmed"}
      user_credential -> user_credential |> Argon2.check_pass(password, opts) |> get_user_struct()
    end
  end

  defp get_user_struct({:ok, %{user_id: user_id}}) do
    {:ok, UserProfiles.get_user(user_id)}
  end

  defp get_user_struct({:error, message}), do: {:error, message}
end

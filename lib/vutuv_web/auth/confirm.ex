defmodule VutuvWeb.Auth.Confirm do
  use Phauxth.Confirm.Base

  alias Vutuv.{Accounts, Accounts.User}
  alias VutuvWeb.Auth.Token

  @impl true
  def authenticate(%{"key" => token}, _user_context, opts) do
    token
    |> Token.verify(opts ++ [max_age: 1200])
    |> get_user()
  end

  defp get_user({:ok, %{"email" => email} = data}) do
    case Accounts.get_by(data) do
      nil -> {:error, "no user found"}
      user -> {:ok, %User{user | current_email: email}}
    end
  end

  defp get_user({:error, message}), do: {:error, message}
end

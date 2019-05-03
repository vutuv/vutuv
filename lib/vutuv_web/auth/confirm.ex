defmodule VutuvWeb.Auth.Confirm do
  use Phauxth.Confirm.Base

  alias Vutuv.{Accounts, Accounts.User}

  @impl true
  def get_user({:ok, %{"email" => email} = data}, _) do
    case Accounts.get_by(data) do
      nil -> {:error, "no user found"}
      user -> {:ok, %User{user | current_email: email}}
    end
  end

  def get_user({:error, message}, _), do: {:error, message}
end

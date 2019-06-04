defmodule Vutuv.Accounts.EmailManager do
  @moduledoc """
  Email address manager.

  This module is needed to remove invalid / unverified email addresses.

  A process is run periodically to check for email addresses that
  have not been verified and for which the verification time limit
  has expired. These email addresses are then deleted.
  """

  use GenServer

  alias Vutuv.Accounts

  @check_frequency 60 * 60_000
  @max_age 1200 + 300

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    Process.send_after(self(), :check_expired, @check_frequency)
    {:ok, %{}}
  end

  def handle_info(:check_expired, state) do
    Process.send_after(self(), :check_expired, @check_frequency)
    Enum.each(Accounts.unverified_email_addresses(@max_age), &handle_unconfirmed(&1))
    {:noreply, state}
  end

  defp handle_unconfirmed(email_address) do
    {:ok, _email_address} = Accounts.delete_email_address(email_address)
  end
end

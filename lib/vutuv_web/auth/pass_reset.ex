defmodule VutuvWeb.Auth.PassReset do
  use Phauxth.Confirm.Base

  alias Phauxth.Confirm.PassReset
  alias VutuvWeb.Auth.Confirm

  @impl true
  def get_user(output, context), do: Confirm.get_user(output, context)

  @impl true
  def report(result, meta), do: PassReset.report(result, meta)
end

defmodule VutuvWeb.Auth.Otp do
  @moduledoc """
  Convenience functions for working with one-time passwords.
  """

  @doc """
  Creates a time-based one-time password.
  """
  def create do
    OneTimePassEcto.Base.gen_totp(get_secret())
  end

  @doc """
  Verifies a time-based one-time password.
  """
  def verify(code) do
    OneTimePassEcto.Base.check_totp(code, get_secret())
  end

  defp get_secret do
    Application.get_env(:vutuv, :otp_secret)
  end
end

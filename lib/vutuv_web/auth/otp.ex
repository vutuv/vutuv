defmodule VutuvWeb.Auth.Otp do
  @moduledoc """
  Convenience functions for working with one-time passwords.
  """

  @doc """
  Creates a time-based one-time password.
  """
  def create(secret) do
    OneTimePassEcto.Base.gen_totp(secret)
  end

  @doc """
  Verifies a time-based one-time password.
  """
  def verify(code, secret) do
    OneTimePassEcto.Base.check_totp(code, secret)
  end
end

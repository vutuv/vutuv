defmodule VutuvWeb.UserView do
  use VutuvWeb, :view

  def public_email_addresses(email_addresses) do
    Enum.filter(email_addresses, &(&1.is_public == true))
  end
end

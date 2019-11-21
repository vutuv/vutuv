defmodule VutuvWeb.Api.EmailAddressView do
  use VutuvWeb, :view

  alias VutuvWeb.Api.EmailAddressView

  def render("index.json", %{email_addresses: email_addresses}) do
    %{data: render_many(email_addresses, EmailAddressView, "email_address.json")}
  end

  def render("show.json", %{email_address: email_address}) do
    %{data: render_one(email_address, EmailAddressView, "email_address.json")}
  end

  def render("email_address.json", %{email_address: email_address}) do
    %{
      id: email_address.id,
      description: email_address.description,
      is_public: email_address.is_public,
      is_primary: email_address.is_primary,
      user_id: email_address.user_id,
      value: email_address.value,
      verified: email_address.verified
    }
  end
end

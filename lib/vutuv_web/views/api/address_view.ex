defmodule VutuvWeb.Api.AddressView do
  use VutuvWeb, :view
  alias VutuvWeb.Api.AddressView

  def render("index.json", %{addresses: addresses}) do
    %{data: render_many(addresses, AddressView, "address.json")}
  end

  def render("show.json", %{address: address}) do
    %{data: render_one(address, AddressView, "address.json")}
  end

  def render("address.json", %{address: address}) do
    %{
      id: address.id,
      city: address.city,
      country: address.country,
      description: address.description,
      line_1: address.line_1,
      line_2: address.line_2,
      line_3: address.line_3,
      line_4: address.line_4,
      state: address.state,
      user_id: address.user_id,
      zip_code: address.zip_code
    }
  end
end

defmodule Vutuv.Api.AddressView do
  use Vutuv.Web, :view
  import Vutuv.Api.ApiHelpers

  @attributes ~w(
    description line_1 line_2 line_3 line_4
    zip_code city state country
  )a

  def render("index.json", %{addresses: addresses}) do
    %{data: render_many(addresses, Vutuv.Api.AddressView, "address.json")}
  end

  def render("index_lite.json", %{addresses: addresses}) do
    %{data: render_many(addresses, Vutuv.Api.AddressView, "address_lite.json")}
  end

  def render("show.json", %{address: address}) do
    %{data: render_one(address, Vutuv.Api.AddressView, "address.json")}
  end

  def render("show_lite.json", %{address: address}) do
    %{data: render_one(address, Vutuv.Api.AddressView, "address_lite.json")}
  end

  def render("address.json", %{address: address} = params) do
    render("address_lite.json", params)
    |> put_attributes(address, @attributes)
  end

  def render("address_lite.json", %{address: address}) do
    %{id: address.id, type: "address"}
  end
end

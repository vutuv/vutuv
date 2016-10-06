defmodule Vutuv.Api.PhoneNumberView do
  use Vutuv.Web, :view
  import Vutuv.Api.ApiHelpers

  @attributes ~w(value number_type)a

  def render("index.json", %{phone_numbers: phone_numbers}) do
    %{data: render_many(phone_numbers, Vutuv.Api.PhoneNumberView, "phone_number.json")}
  end

  def render("index_lite.json", %{phone_numbers: phone_numbers}) do
    %{data: render_many(phone_numbers, Vutuv.Api.PhoneNumberView, "phone_number_lite.json")}
  end

  def render("show.json", %{phone_number: phone_number}) do
    %{data: render_one(phone_number, Vutuv.Api.PhoneNumberView, "phone_number.json")}
  end

  def render("show_lite.json", %{phone_number: phone_number}) do
    %{data: render_one(phone_number, Vutuv.Api.PhoneNumberView, "phone_number_lite.json")}
  end

  def render("phone_number.json", %{phone_number: phone_number} = params) do
    render("phone_number_lite.json", params)
    |> put_attributes(phone_number, @attributes)
  end

  def render("phone_number_lite.json", %{phone_number: phone_number}) do
    %{id: phone_number.id, type: "phone_number"}
  end
end

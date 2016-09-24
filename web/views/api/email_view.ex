defmodule Vutuv.Api.EmailView do
  use Vutuv.Web, :view
  import Vutuv.Api.ApiHelpers

  @attributes ~w(value md5sum)a

  def render("index.json", %{emails: emails}) do
    %{data: render_many(emails,  Vutuv.Api.EmailView, "email.json")}
  end

  def render("index_lite.json", %{emails: emails}) do
    %{data: render_many(emails,  Vutuv.Api.EmailView, "email_lite.json")}
  end

  def render("show.json", %{email: email}) do
    %{data: render_one(email,  Vutuv.Api.EmailView, "email.json")}
  end

  def render("show_lite.json", %{email: email}) do
    %{data: render_one(email,  Vutuv.Api.EmailView, "email_lite.json")}
  end

  def render("email.json", %{email: email} = params) do
    render("email_lite.json", params)
    |> Map.put(:attributes, to_attributes(email, @attributes))
  end

  def render("email_lite.json", %{email: email}) do
    %{id: email.id, type: "email"}
  end
end

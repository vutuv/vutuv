defmodule VutuvWeb.Api.SessionView do
  use VutuvWeb, :view

  def render("info.json", %{info: token}) do
    %{access_token: token}
  end
end

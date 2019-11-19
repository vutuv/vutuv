defmodule VutuvWeb.Api.PasswordResetView do
  use VutuvWeb, :view

  def render("error.json", %{error: message}) do
    %{errors: %{detail: message}}
  end

  def render("info.json", %{info: message, key: key}) do
    %{info: %{detail: message, key: key}}
  end

  def render("info.json", %{info: message}) do
    %{info: %{detail: message}}
  end
end

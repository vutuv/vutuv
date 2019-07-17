defmodule VutuvWeb.PostView do
  use VutuvWeb, :view

  def intro(body) do
    String.slice(body, 0, 40) <> "..."
  end
end

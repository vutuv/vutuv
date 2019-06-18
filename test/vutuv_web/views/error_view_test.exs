defmodule VutuvWeb.ErrorViewTest do
  use VutuvWeb.ConnCase, async: true

  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(VutuvWeb.ErrorView, "404.html", []) =~
             "we cannot find the page you were looking for"
  end

  test "renders 500.html" do
    assert render_to_string(VutuvWeb.ErrorView, "500.html", []) == "Internal Server Error"
  end
end

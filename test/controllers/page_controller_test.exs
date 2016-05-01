defmodule Vutuv.PageControllerTest do
  use Vutuv.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to vutuv!"
  end
end

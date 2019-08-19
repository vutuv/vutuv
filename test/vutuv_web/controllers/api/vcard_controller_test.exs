defmodule VutuvWeb.Api.VcardControllerTest do
  use VutuvWeb.ConnCase

  import Vutuv.Factory

  test "shows vcard for valid user", %{conn: conn} do
    user = insert(:user)
    [email_address] = user.email_addresses
    conn = get(conn, Routes.api_user_vcard_path(conn, :vcard, user))
    assert conn.status == 200
    vcard = conn.resp_body
    assert vcard =~ "BEGIN:VCARD\nVERSION:3.0"
    assert vcard =~ "#{user.full_name}"
    assert vcard =~ "#{email_address.value}"
    assert vcard =~ "\nEND:VCARD"
  end

  test "returns 404 when no user found", %{conn: conn} do
    assert_error_sent 404, fn ->
      get(conn, Routes.api_user_vcard_path(conn, :vcard, -1))
    end
  end
end

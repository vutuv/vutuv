defmodule VutuvWeb.TranslationTest do
  use VutuvWeb.ConnCase

  describe "default messages" do
    test "returns English for default locale", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "Already signed up"
    end

    test "returns German if locale is de", %{conn: conn} do
      Gettext.put_locale(VutuvWeb.Gettext, "de")
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "Einloggen hier"
    end
  end

  describe "error messages" do
    test "returns English for default locale", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: %{email: nil})
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end

    test "returns German if locale is de", %{conn: conn} do
      Gettext.put_locale(VutuvWeb.Gettext, "de")
      conn = post(conn, Routes.user_path(conn, :create), user: %{email: nil})
      assert html_response(conn, 200) =~ "darf nicht leer sein"
    end
  end
end

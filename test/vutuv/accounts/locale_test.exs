defmodule Vutuv.Accounts.LocaleTest do
  use ExUnit.Case

  alias Vutuv.Accounts.Locale

  test "locale with top quality is selected" do
    al = "en-ca,en;q=0.8,en-us;q=0.6,de-de;q=0.4,de;q=0.2"
    assert Locale.parse_al(al) == "en_CA"
    al = "en;q=0.8,en-us;q=0.6,de-de;q=0.4,de;q=0.2"
    assert Locale.parse_al(al) == "en"
    al = "en;q=0.6,en-us;q=0.4,de-de;q=0.2,de;q=0.8"
    assert Locale.parse_al(al) == "de"
  end

  test "unsupported locale is not selected" do
    al = "zh,en;q=0.6,en-us;q=0.4,de-de;q=0.2,de;q=0.8"
    assert Locale.parse_al(al) == "de"
  end

  test "invalid input returns default locale" do
    al = "garbage"
    assert Locale.parse_al(al) == Locale.parse_al("")
  end
end

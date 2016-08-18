defmodule Vutuv.MagicLinkTest do
  use Vutuv.ModelCase

  alias Vutuv.MagicLink

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = MagicLink.changeset(%MagicLink{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = MagicLink.changeset(%MagicLink{}, @invalid_attrs)
    refute changeset.valid?
  end
end

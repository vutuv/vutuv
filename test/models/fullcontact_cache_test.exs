defmodule Vutuv.FullcontactCacheTest do
  use Vutuv.ModelCase

  alias Vutuv.FullcontactCache

  @valid_attrs %{content: "some content", email_address: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = FullcontactCache.changeset(%FullcontactCache{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = FullcontactCache.changeset(%FullcontactCache{}, @invalid_attrs)
    refute changeset.valid?
  end
end

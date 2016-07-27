defmodule Vutuv.SlugTest do
  use Vutuv.ModelCase

  alias Vutuv.Slug

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Slug.changeset(%Slug{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Slug.changeset(%Slug{}, @invalid_attrs)
    refute changeset.valid?
  end
end

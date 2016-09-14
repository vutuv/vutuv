defmodule Vutuv.SearchQueryTest do
  use Vutuv.ModelCase

  alias Vutuv.SearchQuery

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SearchQuery.changeset(%SearchQuery{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SearchQuery.changeset(%SearchQuery{}, @invalid_attrs)
    refute changeset.valid?
  end
end

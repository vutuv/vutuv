defmodule Vutuv.SearchQueryResultTest do
  use Vutuv.ModelCase

  alias Vutuv.SearchQueryResult

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SearchQueryResult.changeset(%SearchQueryResult{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SearchQueryResult.changeset(%SearchQueryResult{}, @invalid_attrs)
    refute changeset.valid?
  end
end

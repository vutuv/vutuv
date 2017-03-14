defmodule Vutuv.DataEnrichmentTest do
  use Vutuv.ModelCase

  alias Vutuv.DataEnrichment

  @valid_attrs %{description: "some content", session_id: 42, source: "some content", user_id: 42, value: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DataEnrichment.changeset(%DataEnrichment{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DataEnrichment.changeset(%DataEnrichment{}, @invalid_attrs)
    refute changeset.valid?
  end
end

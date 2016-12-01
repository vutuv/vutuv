defmodule Vutuv.SkillSynonymTest do
  use Vutuv.ModelCase

  alias Vutuv.SkillSynonym

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SkillSynonym.changeset(%SkillSynonym{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SkillSynonym.changeset(%SkillSynonym{}, @invalid_attrs)
    refute changeset.valid?
  end
end

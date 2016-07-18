defmodule Vutuv.SkillTest do
  use Vutuv.ModelCase

  alias Vutuv.Skill

  @valid_attrs %{description: "some content", downcase_name: "some content", name: "some content", slug: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Skill.changeset(%Skill{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Skill.changeset(%Skill{}, @invalid_attrs)
    refute changeset.valid?
  end
end

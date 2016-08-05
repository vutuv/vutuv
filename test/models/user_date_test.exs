defmodule Vutuv.UserDateTest do
  use Vutuv.ModelCase

  alias Vutuv.UserDate

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserDate.changeset(%UserDate{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserDate.changeset(%UserDate{}, @invalid_attrs)
    refute changeset.valid?
  end
end

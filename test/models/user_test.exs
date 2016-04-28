defmodule Vutuv.UserTest do
  use Vutuv.ModelCase

  alias Vutuv.User

  @valid_attrs %{birthdate: "2010-04-17", first_name: "some content", gender: "some content", honorific_prefix: "some content", honorific_suffix: "some content", last_name: "some content", middlename: "some content", nickname: "some content", verified: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end

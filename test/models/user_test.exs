defmodule Vutuv.UserTest do
  use Vutuv.ModelCase

  alias Vutuv.User

  @valid_attrs [%{first_name: "John", last_name: "Smith", nickname: "john"},
                %{first_name: "John", last_name: "Smith"},
                %{first_name: "John"},
                %{last_name: "Smith", nickname: "john"},
                %{last_name: "Smith"},
                %{nickname: "john"}]
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    for valid_attrs <- @valid_attrs do
      changeset = User.changeset(%User{}, valid_attrs)
      assert changeset.valid?
    end
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end

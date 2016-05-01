defmodule Vutuv.EmailTest do
  use Vutuv.ModelCase

  alias Vutuv.Email

  @valid_attrs %{value: "john@example.com", user_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Email.changeset(%Email{}, @valid_attrs)
    assert changeset.valid?
  end

  test "value must contain at least an @" do
    attrs = %{@valid_attrs | value: "fooexample.com"}
    assert {:value, "has invalid format"} in errors_on(%Email{}, attrs)
  end

  test "changeset with invalid attributes" do
    changeset = Email.changeset(%Email{}, @invalid_attrs)
    refute changeset.valid?
  end
end

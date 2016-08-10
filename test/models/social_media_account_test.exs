defmodule Vutuv.SocialMediaAccountTest do
  use Vutuv.ModelCase

  alias Vutuv.SocialMediaAccount

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SocialMediaAccount.changeset(%SocialMediaAccount{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SocialMediaAccount.changeset(%SocialMediaAccount{}, @invalid_attrs)
    refute changeset.valid?
  end
end

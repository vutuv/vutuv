defmodule Vutuv.OAuthProviderTest do
  use Vutuv.ModelCase

  alias Vutuv.OAuthProvider

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OAuthProvider.changeset(%OAuthProvider{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OAuthProvider.changeset(%OAuthProvider{}, @invalid_attrs)
    refute changeset.valid?
  end
end

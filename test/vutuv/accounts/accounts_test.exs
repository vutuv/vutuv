defmodule Vutuv.AccountsTest do
  use Vutuv.DataCase

  import VutuvWeb.AuthTestHelpers

  alias Vutuv.Accounts
  alias Vutuv.Accounts.{EmailAddress, User}

  @create_attrs %{"email" => "fred@example.com", "password" => "reallyHard2gue$$"}
  @update_attrs %{"email" => "frederick@example.com", "password" => "reallyHard2gue$$"}
  @invalid_attrs %{"email" => "", "password" => ""}

  def fixture(:user, attrs \\ @create_attrs) do
    {:ok, user} = Accounts.create_user(attrs)
    user
  end

  describe "read user data" do
    test "list_users/1 returns all users" do
      user = fixture(:user)
      assert Accounts.list_users() == [user]
    end

    test "get returns the user with given id" do
      user = fixture(:user)
      assert Accounts.get_user(user.id) == user
    end

    test "change_user/1 returns a user changeset" do
      user = fixture(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "write user data" do
    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@create_attrs)
      email_address = hd(user.email_addresses)
      assert email_address.value == "fred@example.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = fixture(:user)
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      email_address = hd(user.email_addresses)
      assert email_address.value == "fred@example.com"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = fixture(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user(user.id)
    end

    test "update password changes the stored hash" do
      %{password_hash: stored_hash} = user = fixture(:user)
      attrs = %{password: "CN8W6kpb"}
      {:ok, %{password_hash: hash}} = Accounts.update_password(user, attrs)
      assert hash != stored_hash
    end

    test "update_password with weak password fails" do
      user = fixture(:user)
      attrs = %{password: "pass"}
      assert {:error, %Ecto.Changeset{}} = Accounts.update_password(user, attrs)
    end
  end

  describe "delete user data" do
    test "delete_user/1 deletes the user" do
      user = fixture(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      refute Accounts.get_user(user.id)
    end
  end

  describe "email_addresses" do
    @valid_email_attrs %{
      "is_public" => "true",
      "description" => "some description",
      "position" => "",
      "value" => "abcdef@vutuv.com",
      "user_id" => "1",
      "verified" => "true"
    }
    @update_email_attrs %{
      is_public: false,
      description: "abcde@gmail.com",
      position: 43,
      user_id: 43,
      value: "abcde@vutuv.com",
      verified: false
    }
    @invalid_email_attrs %{
      is_public: nil,
      description: nil,
      position: nil,
      user_id: nil,
      value: nil,
      verified: nil
    }

    setup do
      user = add_user("abcde@vutuv.com")
      %{@valid_email_attrs | "user_id" => user.id}
      {:ok, email_address} = Accounts.create_email_address(@valid_email_attrs)
      {:ok, %{email_address: email_address}}
    end
  end
end

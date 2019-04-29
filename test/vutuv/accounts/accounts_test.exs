defmodule Vutuv.AccountsTest do
  use Vutuv.DataCase

  alias Vutuv.{Accounts, Accounts.EmailAddress, Accounts.User}
  alias Vutuv.Biographies.Profile

  @create_user_attrs %{
    "email" => "fred@example.com",
    "password" => "reallyHard2gue$$",
    "gender" => "male",
    "first_name" => "fred",
    "last_name" => "frederickson"
  }
  @invalid_user_attrs %{"email" => "", "password" => ""}
  @create_email_attrs %{
    "is_public" => true,
    "description" => "backup email",
    "value" => "abcdef@vutuv.com",
    "verified" => "true"
  }
  @update_email_attrs %{
    "is_public" => false
  }
  @invalid_email_attrs %{
    "value" => nil
  }

  def create_user(attrs \\ @create_user_attrs) do
    {:ok, user} = Accounts.create_user(attrs)
    user
  end

  def create_email_address(user, attrs \\ @create_email_attrs) do
    {:ok, email_address} = Accounts.create_email_address(user, attrs)
    email_address
  end

  describe "read user data" do
    test "list_users/1 returns all users" do
      user = create_user()
      assert Accounts.list_users() == [user]
    end

    test "get_user returns the user with given id" do
      user = create_user()
      assert Accounts.get_user(user.id) == user
    end

    test "get_user returns email_addresses and profile" do
      user = create_user()
      user = Accounts.get_user(user.id)
      assert [%EmailAddress{value: "fred@example.com", position: 1}] = user.email_addresses

      assert %Profile{gender: "male", first_name: "fred", last_name: "frederickson"} =
               user.profile
    end

    test "change_user/1 returns a user changeset" do
      user = create_user()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "write user data" do
    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@create_user_attrs)
      email_address = hd(user.email_addresses)
      assert email_address.value == "fred@example.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_user_attrs)
    end

    test "update password changes the stored hash" do
      %{password_hash: stored_hash} = user = create_user()
      attrs = %{password: "CN8W6kpb"}
      {:ok, %{password_hash: hash}} = Accounts.update_password(user, attrs)
      assert hash != stored_hash
    end

    test "update_password with weak password fails" do
      user = create_user()
      attrs = %{password: "pass"}
      assert {:error, %Ecto.Changeset{}} = Accounts.update_password(user, attrs)
    end
  end

  describe "delete user data" do
    test "delete_user/1 deletes the user" do
      user = create_user()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      refute Accounts.get_user(user.id)
    end
  end

  describe "read email_address data" do
    test "list_email_addresses/1 returns all email addresses" do
      user = create_user()
      email_address = create_email_address(user)
      assert email_address in Accounts.list_email_addresses(user)
    end

    test "get_email_address returns the email_address with given id" do
      user = create_user()
      email_address = create_email_address(user)
      assert Accounts.get_email_address(email_address.id) == email_address
    end

    test "change_email_address/1 returns a email_address changeset" do
      user = create_user()
      email_address = create_email_address(user)
      assert %Ecto.Changeset{} = Accounts.change_email_address(email_address)
    end
  end

  describe "write email_address data" do
    test "create_email_address/1 with valid data creates a email_address" do
      user = create_user()

      assert {:ok, %EmailAddress{} = email_address} =
               Accounts.create_email_address(user, @create_email_attrs)

      assert email_address.value == "abcdef@vutuv.com"
      assert email_address.position == 2
    end

    test "create_email_address/1 with invalid data returns error changeset" do
      user = create_user()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_email_address(user, @invalid_email_attrs)
    end

    test "update email_address with valid data updates the email_address" do
      user = create_user()
      email_address = create_email_address(user)
      assert email_address.is_public == true

      assert {:ok, %EmailAddress{} = email_address} =
               Accounts.update_email_address(email_address, @update_email_attrs)

      assert email_address.is_public == false
    end

    test "update email_address with invalid data returns error changeset" do
      user = create_user()
      email_address = create_email_address(user)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_email_address(email_address, @invalid_email_attrs)
    end
  end
end

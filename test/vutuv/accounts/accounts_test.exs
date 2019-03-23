defmodule Vutuv.AccountsTest do
  use Vutuv.DataCase

  import VutuvWeb.AuthCase

  alias Vutuv.Accounts
  alias Vutuv.Accounts.{User, EmailAddress}

  @create_attrs %{"email" => "fred@example.com", "password" => "reallyHard2gue$$"}
  @update_attrs %{"email" => "frederick@example.com"}
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
      #
      assert email_address.value == "fred@example.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    @tag :skip
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
    alias Vutuv.Accounts.EmailAddress

    # @valid_email_attrs %{
    #   is_public: true,
    #   description: "some description",
    #   position: 42,
    #   user_id: 42,
    #   value: "abcde@vutuv.com",
    #   verified: true
    # }
    @valid_email_attrs %{
      # is_public: false,
      # description: "some description",
      # position: 42,
      # user_id: 42,
      # value: "abcde@vutuv.com",
      # verified: false

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

    # def email_address_fixture(attrs \\ %{}) do
    #   {:ok, email_address} =
    #     attrs
    #     |> Enum.into(@valid_email_attrs)
    #     |> Accounts.create_email_address()

    #   email_address
    # end

    @tag :skip
    test "list_email_addresses/0 returns all email_addresses", %{email_address: email_address} do
      assert Accounts.list_email_addresses() == [email_address]
    end

    #   @tag :skip
    #   test "get_email_address/1 returns the email_address with given id", %{email_address: email_address} do
    #     assert Accounts.get_email_address(email_address.id) == email_address
    #   end

    #   @tag :skip
    #   test "create_email_address/1 with valid data creates a email_address" do
    #     assert {:ok, %EmailAddress{} = email_address} = Accounts.create_email_address(@valid_email_attrs)
    #     assert email_address.is_public == true
    #     assert email_address.description == "some description"
    #     assert email_address.position == 42
    #     assert email_address.user_id == 42
    #     assert email_address.value == "somevalue@example.com"
    #     assert email_address.verified == true
    #   end

    #   @tag :skip
    #   test "create_email_address/1 with invalid data returns error changeset" do
    #     assert {:error, %Ecto.Changeset{}} = Accounts.create_email_address(@invalid_email_attrs)
    #   end

    #   @tag :skip
    #   test "update_email_address/2 with valid data updates the email_address" do
    #     email_address = email_address_fixture()

    #     assert {:ok, %EmailAddress{} = email_address} =
    #              Accounts.update_email_address(email_address, @update_email_attrs)

    #     assert email_address.is_public == false
    #     assert email_address.description == "some updated description"
    #     assert email_address.position == 43
    #     assert email_address.user_id == 43
    #     assert email_address.value == "somevalue@example.com"
    #     assert email_address.verified == false
    #   end

    #   @tag :skip
    #   test "update_email_address/2 with invalid data returns error changeset" do
    #     email_address = email_address_fixture()

    #     assert {:error, %Ecto.Changeset{}} =
    #              Accounts.update_email_address(email_address, @invalid_email_attrs)

    #     assert email_address == Accounts.get_email_address(email_address.id)
    #   end

    #   @tag :skip
    #   test "delete_email_address/1 deletes the email_address" do
    #     email_address = email_address_fixture()
    #     assert {:ok, %EmailAddress{}} = Accounts.delete_email_address(email_address)
    #     refute Accounts.get_email_address(email_address.id)
    #   end

    #   @tag :skip
    #   test "change_email_address/1 returns a email_address changeset" do
    #     email_address = email_address_fixture()
    #     assert %Ecto.Changeset{} = Accounts.change_email_address(email_address)
    #   end
  end
end

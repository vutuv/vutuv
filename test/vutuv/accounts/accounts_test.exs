defmodule Vutuv.AccountsTest do
  use Vutuv.DataCase

  alias Vutuv.Accounts
  alias Vutuv.Accounts.User

  @create_attrs %{email: "fred@example.com", password: "reallyHard2gue$$"}
  @update_attrs %{email: "frederick@example.com"}
  @invalid_attrs %{email: "", password: ""}

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
      assert user.email == "fred@example.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = fixture(:user)
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "frederick@example.com"
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

    @valid_attrs %{description: "some description", is_public: true, position: 42, value: "some value", verified: true}
    @update_attrs %{description: "some updated description", is_public: false, position: 43, value: "some updated value", verified: false}
    @invalid_attrs %{description: nil, is_public: nil, position: nil, value: nil, verified: nil}

    def email_address_fixture(attrs \\ %{}) do
      {:ok, email_address} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_email_address()

      email_address
    end

    test "list_email_addresses/0 returns all email_addresses" do
      email_address = email_address_fixture()
      assert Accounts.list_email_addresses() == [email_address]
    end

    test "get_email_address!/1 returns the email_address with given id" do
      email_address = email_address_fixture()
      assert Accounts.get_email_address!(email_address.id) == email_address
    end

    test "create_email_address/1 with valid data creates a email_address" do
      assert {:ok, %EmailAddress{} = email_address} = Accounts.create_email_address(@valid_attrs)
      assert email_address.description == "some description"
      assert email_address.is_public == true
      assert email_address.position == 42
      assert email_address.value == "some value"
      assert email_address.verified == true
    end

    test "create_email_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_email_address(@invalid_attrs)
    end

    test "update_email_address/2 with valid data updates the email_address" do
      email_address = email_address_fixture()
      assert {:ok, %EmailAddress{} = email_address} = Accounts.update_email_address(email_address, @update_attrs)
      assert email_address.description == "some updated description"
      assert email_address.is_public == false
      assert email_address.position == 43
      assert email_address.value == "some updated value"
      assert email_address.verified == false
    end

    test "update_email_address/2 with invalid data returns error changeset" do
      email_address = email_address_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_email_address(email_address, @invalid_attrs)
      assert email_address == Accounts.get_email_address!(email_address.id)
    end

    test "delete_email_address/1 deletes the email_address" do
      email_address = email_address_fixture()
      assert {:ok, %EmailAddress{}} = Accounts.delete_email_address(email_address)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_email_address!(email_address.id) end
    end

    test "change_email_address/1 returns a email_address changeset" do
      email_address = email_address_fixture()
      assert %Ecto.Changeset{} = Accounts.change_email_address(email_address)
    end
  end

  describe "roles" do
    alias Vutuv.Accounts.Roles

    @valid_attrs %{description: "some description", group_name: "some group_name"}
    @update_attrs %{description: "some updated description", group_name: "some updated group_name"}
    @invalid_attrs %{description: nil, group_name: nil}

    def roles_fixture(attrs \\ %{}) do
      {:ok, roles} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_roles()

      roles
    end

    test "list_roles/0 returns all roles" do
      roles = roles_fixture()
      assert Accounts.list_roles() == [roles]
    end

    test "get_roles!/1 returns the roles with given id" do
      roles = roles_fixture()
      assert Accounts.get_roles!(roles.id) == roles
    end

    test "create_roles/1 with valid data creates a roles" do
      assert {:ok, %Roles{} = roles} = Accounts.create_roles(@valid_attrs)
      assert roles.description == "some description"
      assert roles.group_name == "some group_name"
    end

    test "create_roles/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_roles(@invalid_attrs)
    end

    test "update_roles/2 with valid data updates the roles" do
      roles = roles_fixture()
      assert {:ok, %Roles{} = roles} = Accounts.update_roles(roles, @update_attrs)
      assert roles.description == "some updated description"
      assert roles.group_name == "some updated group_name"
    end

    test "update_roles/2 with invalid data returns error changeset" do
      roles = roles_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_roles(roles, @invalid_attrs)
      assert roles == Accounts.get_roles!(roles.id)
    end

    test "delete_roles/1 deletes the roles" do
      roles = roles_fixture()
      assert {:ok, %Roles{}} = Accounts.delete_roles(roles)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_roles!(roles.id) end
    end

    test "change_roles/1 returns a roles changeset" do
      roles = roles_fixture()
      assert %Ecto.Changeset{} = Accounts.change_roles(roles)
    end
  end
end

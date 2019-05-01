defmodule Vutuv.AccountsTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.{Accounts, Accounts.EmailAddress, Accounts.User}
  alias Vutuv.{Biographies, Biographies.Profile}

  @create_user_attrs %{
    "email" => "fred@example.com",
    "password" => "reallyHard2gue$$",
    "gender" => "male",
    "first_name" => "fred",
    "last_name" => "frederickson"
  }
  @create_email_attrs %{
    "is_public" => true,
    "description" => "backup email",
    "value" => "abcdef@vutuv.com"
  }

  describe "read user data" do
    setup [:create_user]

    test "list_users/1 returns all users", %{user: user} do
      assert Accounts.list_users() == [user]
      insert(:user)
      assert length(Accounts.list_users()) == 2
    end

    test "get_user returns the user with given id", %{user: user} do
      assert Accounts.get_user(user.id) == user
    end

    test "get_user returns email_addresses and profile", %{user: user} do
      user = Accounts.get_user(user.id)
      assert [%EmailAddress{value: "fred@example.com", position: 1}] = user.email_addresses

      assert %Profile{gender: "male", first_name: "fred", last_name: "frederickson"} =
               user.profile
    end

    test "change_user/1 returns a user changeset", %{user: user} do
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "write user data" do
    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@create_user_attrs)
      assert [%EmailAddress{value: value, position: 1}] = user.email_addresses
      assert value == "fred@example.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      invalid_attrs = Map.merge(@create_user_attrs, %{"email" => ""})
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(invalid_attrs)
      assert %{email_addresses: [%{value: ["can't be blank"]}]} = errors_on(changeset)
      invalid_attrs = Map.merge(@create_user_attrs, %{"password" => nil})
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(invalid_attrs)
      assert %{password: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid email returns email_addresses error" do
      attrs = Map.merge(@create_user_attrs, %{"email" => "invalid_email"})
      assert {:error, changeset} = Accounts.create_user(attrs)
      assert %{email_addresses: [%{value: ["has invalid format"]}]} = errors_on(changeset)
    end

    test "no first name or last name returns profile error" do
      attrs = Map.merge(@create_user_attrs, %{"first_name" => "", "last_name" => ""})
      assert {:error, changeset} = Accounts.create_user(attrs)

      assert %{
               profile: %{
                 first_name: ["First name or last name must be present"],
                 last_name: ["First name or last name must be present"]
               }
             } = errors_on(changeset)
    end

    test "update password changes the stored hash" do
      %{password_hash: stored_hash} = user = insert(:user)
      attrs = %{password: "CN8W6kpb"}
      {:ok, %{password_hash: hash}} = Accounts.update_password(user, attrs)
      assert hash != stored_hash
    end

    test "update_password with weak password fails" do
      user = insert(:user)
      attrs = %{password: "pass"}
      assert {:error, %Ecto.Changeset{}} = Accounts.update_password(user, attrs)
    end
  end

  describe "delete user data" do
    setup [:create_user]

    test "delete_user/1 deletes the user and associated tables", %{user: user} do
      [email_address] = user.email_addresses
      profile = user.profile
      assert {:ok, %User{}} = Accounts.delete_user(user)
      refute Accounts.get_user(user.id)
      refute Accounts.get_email_address(email_address.id)
      refute Biographies.get_profile(profile.id)
    end
  end

  describe "read email_address data" do
    setup [:create_user, :create_email_address]

    test "list_email_addresses/1 returns all a user's email addresses", %{
      email_address: email_address,
      user: user
    } do
      assert length(Accounts.list_email_addresses(user)) == 2
      assert email_address in Accounts.list_email_addresses(user)
      insert(:email_address, %{user: user})
      assert length(Accounts.list_email_addresses(user)) == 3
    end

    test "get_email_address returns the email_address with given id", %{
      email_address: email_address
    } do
      assert Accounts.get_email_address(email_address.id) == email_address
    end

    test "change_email_address/1 returns a email_address changeset", %{
      email_address: email_address
    } do
      assert %Ecto.Changeset{} = Accounts.change_email_address(email_address)
    end
  end

  describe "write email_address data" do
    setup [:create_user]

    test "create_email_address/1 with valid data creates a email_address", %{user: user} do
      assert {:ok, %EmailAddress{} = email_address} =
               Accounts.create_email_address(user, @create_email_attrs)

      assert email_address.value == "abcdef@vutuv.com"
      assert email_address.position == 2
    end

    test "position of new email_address is last", %{user: user} do
      [email_address] = user.email_addresses
      assert email_address.position == 1
      email_attrs = Map.merge(@create_email_attrs, %{"value" => "xyz@vutuv.com"})
      {:ok, email_address} = Accounts.create_email_address(user, email_attrs)
      assert email_address.position == 2
      email_attrs = Map.merge(@create_email_attrs, %{"value" => "zyx@vutuv.com"})
      user = Accounts.get_user(user.id)
      {:ok, email_address} = Accounts.create_email_address(user, email_attrs)
      assert email_address.position == 3
    end

    test "create_email_address/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_email_address(user, %{"value" => nil})
    end

    test "cannot set verified to true at creation time", %{user: user} do
      attrs = Map.merge(@create_email_attrs, %{"verified" => true})
      assert {:ok, %EmailAddress{verified: false}} = Accounts.create_email_address(user, attrs)
    end

    test "update email_address with valid data updates the email_address", %{user: user} do
      email_address = insert(:email_address, %{user: user})
      assert email_address.is_public == true

      assert {:ok, %EmailAddress{} = email_address} =
               Accounts.update_email_address(email_address, %{"is_public" => false})

      assert email_address.is_public == false
    end

    test "update email_address with invalid data returns error changeset", %{user: user} do
      email_address = insert(:email_address, %{user: user})
      too_long = String.duplicate("too long", 32)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_email_address(email_address, %{"description" => too_long})
    end
  end

  describe "delete email_address data" do
    setup [:create_user, :create_email_address]

    test "delete_email_address/1 deletes the email_address", %{email_address: email_address} do
      assert {:ok, %EmailAddress{}} = Accounts.delete_email_address(email_address)
      refute Accounts.get_email_address(email_address.id)
    end
  end

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(@create_user_attrs)
    {:ok, %{user: user}}
  end

  defp create_email_address(%{user: user}) do
    {:ok, email_address} = Accounts.create_email_address(user, @create_email_attrs)
    {:ok, %{email_address: email_address}}
  end
end

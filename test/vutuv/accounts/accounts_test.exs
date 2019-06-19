defmodule Vutuv.AccountsTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.{Accounts, Accounts.EmailAddress, Accounts.EmailManager, Accounts.User, Repo}
  alias Vutuv.{Biographies, Biographies.Profile}

  @create_user_attrs %{
    "email" => "fred@example.com",
    "password" => "reallyHard2gue$$",
    "profile" => %{
      "gender" => "male",
      "full_name" => "fred frederickson"
    }
  }
  @create_email_attrs %{
    "is_public" => true,
    "description" => "backup email",
    "value" => "abcdef@example.com"
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
      assert %Profile{gender: "male", full_name: "fred frederickson"} = user.profile
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

    test "duplicate email cannot be created" do
      assert {:ok, %User{} = user} = Accounts.create_user(@create_user_attrs)
      assert [%EmailAddress{value: value, position: 1}] = user.email_addresses
      assert value == "fred@example.com"
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(@create_user_attrs)
      assert %{email_addresses: [%{value: ["has already been taken"]}]} = errors_on(changeset)
    end

    test "invalid email returns email_addresses error" do
      attrs = Map.merge(@create_user_attrs, %{"email" => "invalid_email"})
      assert {:error, changeset} = Accounts.create_user(attrs)
      assert %{email_addresses: [%{value: ["has invalid format"]}]} = errors_on(changeset)
    end

    test "no full name returns profile error" do
      attrs = Map.merge(@create_user_attrs, %{"profile" => %{"full_name" => ""}})
      assert {:error, changeset} = Accounts.create_user(attrs)

      assert %{profile: %{full_name: ["can't be blank"], gender: ["can't be blank"]}} =
               errors_on(changeset)
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

    test "get_user_email_address returns a specific user's email_address", %{
      user: user,
      email_address: email_address
    } do
      assert Accounts.get_user_email_address(user, email_address.id) == email_address
    end

    test "get_user_email_address returns returns nil for other user's email_address", %{
      email_address: email_address
    } do
      other = insert(:user)
      refute Accounts.get_user_email_address(other, email_address.id)
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

      assert email_address.value == "abcdef@example.com"
      assert email_address.position == 2
    end

    test "position of new email_address is last", %{user: user} do
      [email_address] = user.email_addresses
      assert email_address.position == 1
      email_attrs = Map.merge(@create_email_attrs, %{"value" => "xyz@example.com"})
      {:ok, email_address} = Accounts.create_email_address(user, email_attrs)
      assert email_address.position == 2
      email_attrs = Map.merge(@create_email_attrs, %{"value" => "zyx@example.com"})
      user = Accounts.get_user(user.id)
      {:ok, email_address} = Accounts.create_email_address(user, email_attrs)
      assert email_address.position == 3
    end

    test "create_email_address/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_email_address(user, %{"value" => nil})
    end

    test "create_email_address/1 with invalid email value returns error", %{user: user} do
      for value <- [
            "@domainsample.com",
            "johndoedomainsample.com",
            "john.doe@domainsample",
            "john.doe@.net",
            "john.doe@domainsample.com2012"
          ] do
        assert {:error, %Ecto.Changeset{} = changeset} =
                 Accounts.create_email_address(user, %{"value" => value})

        assert %{value: ["has invalid format"]} = errors_on(changeset)
      end
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

    test "cannot update email_address value", %{user: user} do
      email_address = insert(:email_address, %{user: user})

      assert {:error, %Ecto.Changeset{} = changeset} =
               Accounts.update_email_address(email_address, %{"value" => "igor@example.com"})

      assert %{value: ["the email_address value cannot be updated"]} = errors_on(changeset)
    end
  end

  describe "delete email_address data" do
    setup [:create_user, :create_email_address]

    test "delete_email_address/1 deletes the email_address", %{email_address: email_address} do
      assert {:ok, %EmailAddress{}} = Accounts.delete_email_address(email_address)
      refute Accounts.get_email_address(email_address.id)
    end
  end

  describe "handle unverified email addresses" do
    setup [:create_user]

    test "unverified and verification expired email is deleted", %{user: %{id: user_id}} do
      expired_inserted_at = DateTime.add(DateTime.truncate(DateTime.utc_now(), :second), -2000)

      Repo.insert!(%EmailAddress{
        inserted_at: expired_inserted_at,
        value: "froderick@example.com",
        user_id: user_id
      })

      assert Accounts.get_email_address_from_value("froderick@example.com")
      send(EmailManager, :check_expired)
      Process.sleep(10)
      refute Accounts.get_email_address_from_value("froderick@example.com")
    end

    test "unverified and verification not expired email is not deleted", %{user: user} do
      Accounts.create_email_address(user, %{"value" => "froderick@example.com"})
      assert Accounts.get_email_address_from_value("froderick@example.com")
      send(EmailManager, :check_expired)
      Process.sleep(10)
      assert Accounts.get_email_address_from_value("froderick@example.com")
    end

    test "verified email is not deleted", %{user: %{id: user_id}} do
      expired_inserted_at = DateTime.add(DateTime.truncate(DateTime.utc_now(), :second), -2000)

      Repo.insert!(%EmailAddress{
        inserted_at: expired_inserted_at,
        value: "froderick@example.com",
        user_id: user_id,
        verified: true
      })

      assert Accounts.get_email_address_from_value("froderick@example.com")
      send(EmailManager, :check_expired)
      Process.sleep(10)
      assert Accounts.get_email_address_from_value("froderick@example.com")
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

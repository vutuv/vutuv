defmodule Vutuv.DevicesTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.{Accounts, Devices, Repo}
  alias Vutuv.Devices.{EmailAddress, EmailManager, PhoneNumber}

  @create_email_attrs %{
    "is_public" => true,
    "description" => "backup email",
    "value" => "abcdef@example.com"
  }
  @valid_phone_attrs %{type: "mobile", value: "+9123450292"}
  @update_phone_attrs %{type: "work", value: "02122229999"}
  @invalid_phone_attrs %{type: nil, value: "abcde"}

  describe "read email_address data" do
    setup [:create_user, :create_email_address]

    test "list_email_addresses/1 returns all a user's email addresses", %{
      email_address: email_address,
      user: user
    } do
      assert length(Devices.list_email_addresses(user)) == 2
      assert email_address in Devices.list_email_addresses(user)
      insert(:email_address, %{user: user})
      assert length(Devices.list_email_addresses(user)) == 3
    end

    test "list_email_addresses/2", %{user: user} do
      attrs = %{
        "is_public" => false,
        "description" => "secret email",
        "value" => "no_i_cant_tell_you@example.com"
      }

      Devices.create_email_address(user, attrs)
      assert length(Devices.list_email_addresses(user)) == 3
      assert length(Devices.list_email_addresses(user, :public)) == 2
    end

    test "get_email_address! returns a specific user's email_address", %{
      user: user,
      email_address: email_address
    } do
      assert Devices.get_email_address!(user, email_address.id) == email_address
    end

    test "get_email_address! returns returns nil for other user's email_address", %{
      email_address: email_address
    } do
      other = insert(:user)

      assert_raise Ecto.NoResultsError, fn ->
        Devices.get_email_address!(other, email_address.id)
      end
    end

    test "change_email_address/1 returns a email_address changeset", %{
      email_address: email_address
    } do
      assert %Ecto.Changeset{} = Devices.change_email_address(email_address)
    end
  end

  describe "write email_address data" do
    setup [:create_user]

    test "create_email_address/1 with valid data creates a email_address", %{user: user} do
      assert {:ok, %EmailAddress{} = email_address} =
               Devices.create_email_address(user, @create_email_attrs)

      assert email_address.value == "abcdef@example.com"
      assert email_address.position == 2
    end

    test "position of new email_address is last", %{user: user} do
      [email_address] = user.email_addresses
      assert email_address.position == 1
      email_attrs = Map.merge(@create_email_attrs, %{"value" => "xyz@example.com"})
      {:ok, email_address} = Devices.create_email_address(user, email_attrs)
      assert email_address.position == 2
      email_attrs = Map.merge(@create_email_attrs, %{"value" => "zyx@example.com"})
      user = Accounts.get_user!(%{"id" => user.id})
      {:ok, email_address} = Devices.create_email_address(user, email_attrs)
      assert email_address.position == 3
    end

    test "create_email_address/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Devices.create_email_address(user, %{"value" => nil})
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
                 Devices.create_email_address(user, %{"value" => value})

        assert %{value: ["has invalid format"]} = errors_on(changeset)
      end
    end

    test "cannot set verified to true at creation time", %{user: user} do
      attrs = Map.merge(@create_email_attrs, %{"verified" => true})
      assert {:ok, %EmailAddress{verified: false}} = Devices.create_email_address(user, attrs)
    end

    test "update email_address with valid data updates the email_address", %{user: user} do
      email_address = insert(:email_address, %{user: user})
      assert email_address.is_public == true

      assert {:ok, %EmailAddress{} = email_address} =
               Devices.update_email_address(email_address, %{"is_public" => false})

      assert email_address.is_public == false
    end

    test "update email_address with invalid data returns error changeset", %{user: user} do
      email_address = insert(:email_address, %{user: user})
      too_long = String.duplicate("too long", 32)

      assert {:error, %Ecto.Changeset{}} =
               Devices.update_email_address(email_address, %{"description" => too_long})
    end

    test "cannot update email_address value", %{user: user} do
      email_address = insert(:email_address, %{user: user})

      assert {:error, %Ecto.Changeset{} = changeset} =
               Devices.update_email_address(email_address, %{"value" => "igor@example.com"})

      assert %{value: ["the email_address value cannot be updated"]} = errors_on(changeset)
    end
  end

  describe "delete email_address data" do
    setup [:create_user, :create_email_address]

    test "delete_email_address/1 deletes the email_address", %{
      email_address: email_address,
      user: user
    } do
      assert {:ok, %EmailAddress{}} = Devices.delete_email_address(email_address)

      assert_raise Ecto.NoResultsError, fn ->
        Devices.get_email_address!(user, email_address.id)
      end
    end
  end

  describe "handle unverified email addresses" do
    setup [:create_user]

    test "unverified and verification expired email is deleted", %{user: user} do
      expired_inserted_at = DateTime.add(DateTime.truncate(DateTime.utc_now(), :second), -2000)

      Repo.insert!(%EmailAddress{
        inserted_at: expired_inserted_at,
        value: "froderick@example.com",
        user_id: user.id
      })

      assert Devices.get_email_address(%{"value" => "froderick@example.com"})
      send(EmailManager, :check_expired)
      Process.sleep(10)
      refute Devices.get_email_address(%{"value" => "froderick@example.com"})
    end

    test "unverified and verification not expired email is not deleted", %{user: user} do
      Devices.create_email_address(user, %{"value" => "froderick@example.com"})
      assert Devices.get_email_address(%{"value" => "froderick@example.com"})
      send(EmailManager, :check_expired)
      Process.sleep(10)
      assert Devices.get_email_address(%{"value" => "froderick@example.com"})
    end

    test "verified email is not deleted", %{user: user} do
      expired_inserted_at = DateTime.add(DateTime.truncate(DateTime.utc_now(), :second), -2000)

      Repo.insert!(%EmailAddress{
        inserted_at: expired_inserted_at,
        value: "froderick@example.com",
        user_id: user.id,
        verified: true
      })

      assert Devices.get_email_address(%{"value" => "froderick@example.com"})
      send(EmailManager, :check_expired)
      Process.sleep(10)
      assert Devices.get_email_address(%{"value" => "froderick@example.com"})
    end
  end

  describe "read phone number data" do
    setup [:create_user, :create_phone_number]

    test "phone_number returns the phone_number with given id", %{
      phone_number: phone_number,
      user: user
    } do
      assert Devices.get_phone_number!(user, phone_number.id) == phone_number
    end

    test "change phone_number/1 returns a phone_number changeset", %{
      phone_number: phone_number
    } do
      assert %Ecto.Changeset{} = Devices.change_phone_number(phone_number)
    end
  end

  describe "write phone_number data" do
    setup [:create_user]

    test "create_phone_number/1 with valid data creates a phone_number", %{user: user} do
      assert {:ok, %PhoneNumber{} = phone_number} =
               Devices.create_phone_number(user, @valid_phone_attrs)

      assert phone_number.value == "+9123450292"
      assert phone_number.type == "mobile"
    end

    test "create_phone_number/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Devices.create_phone_number(user, %{"value" => nil})
    end

    test "update phone_number with valid data updates the phone_number", %{user: user} do
      phone_number = insert(:phone_number, %{user: user})

      assert {:ok, %PhoneNumber{} = phone_number} =
               Devices.update_phone_number(phone_number, @update_phone_attrs)

      assert phone_number.type == "work"
      assert phone_number.value == "02122229999"
    end

    test "update phone_number with invalid data returns error changeset", %{user: user} do
      phone_number = insert(:phone_number, %{user: user})

      assert {:error, %Ecto.Changeset{}} =
               Devices.update_phone_number(phone_number, @invalid_phone_attrs)
    end
  end

  describe "delete phone_number data" do
    setup [:create_user, :create_phone_number]

    test "delete_phone_number/1 deletes the phone_number", %{
      phone_number: phone_number,
      user: user
    } do
      assert {:ok, %PhoneNumber{}} = Devices.delete_phone_number(phone_number)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_phone_number!(user, phone_number.id) end
    end
  end

  defp create_user(_) do
    user = insert(:user)
    {:ok, %{user: user}}
  end

  defp create_email_address(%{user: user}) do
    {:ok, email_address} = Devices.create_email_address(user, @create_email_attrs)
    {:ok, %{email_address: email_address}}
  end

  defp create_phone_number(%{user: user}) do
    {:ok, phone_number} = Devices.create_phone_number(user, @valid_phone_attrs)
    {:ok, %{phone_number: phone_number}}
  end
end

defmodule Vutuv.AccountsTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.{Accounts, Repo}
  alias Vutuv.Accounts.{EmailAddress, EmailManager, PhoneNumber, User}

  @accept_language "en-ca,en;q=0.8,en-us;q=0.6,de-de;q=0.4,de;q=0.2"
  @create_user_attrs %{
    "email" => "fred@example.com",
    "password" => "reallyHard2gue$$",
    "accept_language" => @accept_language,
    "gender" => "male",
    "full_name" => "fred frederickson"
  }
  @create_email_attrs %{
    "is_public" => true,
    "description" => "backup email",
    "value" => "abcdef@example.com"
  }
  @valid_phone_attrs %{type: "mobile", value: "+9123450292"}
  @update_phone_attrs %{type: "work", value: "02122229999"}
  @invalid_phone_attrs %{type: nil, value: "abcde"}

  describe "read user data" do
    setup [:create_user]

    test "list_users/0 returns all users", %{user: user} do
      [user_1] = Accounts.list_users()
      assert user_1.id == user.id
      assert user_1.full_name == user.full_name
      assert length(Accounts.list_users()) == 1
      insert(:user)
      assert length(Accounts.list_users()) == 2
    end

    test "paginate_users/1 returns the users in a paginated struct", %{user: user} do
      %Scrivener.Page{entries: [user_1]} = Accounts.paginate_users(%{})
      assert user_1.id == user.id
      assert user_1.full_name == user.full_name
      assert %Scrivener.Page{total_entries: 1} = Accounts.paginate_users(%{})
      insert(:user)
      assert %Scrivener.Page{total_entries: 2} = Accounts.paginate_users(%{})
    end

    test "get_user returns the user with given slug", %{user: user} do
      user_1 = Accounts.get_user(%{"slug" => user.slug})
      assert user_1.id == user.id
      assert user_1.full_name == user.full_name
      assert user_1.gender == user.gender
      refute Ecto.assoc_loaded?(user_1.user_credential)
    end

    test "change_user/1 returns a user changeset", %{user: user} do
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "create user data" do
    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@create_user_attrs)
      assert user.accept_language == @accept_language
      assert user.gender == "male"
      assert user.locale == "en_CA"
      assert [%EmailAddress{value: value, position: 1}] = user.email_addresses
      assert value == "fred@example.com"
    end

    test "noindex is correctly set in create_user/1" do
      assert {:ok, %User{} = user} = Accounts.create_user(@create_user_attrs)
      assert user.noindex == false

      attrs =
        Map.merge(@create_user_attrs, %{"email" => "froderick@example.com", "noindex" => true})

      assert {:ok, %User{} = user} = Accounts.create_user(attrs)
      assert user.noindex == true
    end

    test "create_user/1 with invalid data returns error changeset" do
      invalid_attrs = Map.merge(@create_user_attrs, %{"email" => ""})
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(invalid_attrs)
      assert %{email_addresses: [%{value: ["can't be blank"]}]} = errors_on(changeset)
      invalid_attrs = Map.merge(@create_user_attrs, %{"password" => nil})
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(invalid_attrs)
      assert %{user_credential: %{password: ["can't be blank"]}} = errors_on(changeset)
    end

    test "returns error when adding a duplicate email" do
      assert {:ok, %User{} = user} = Accounts.create_user(@create_user_attrs)
      assert [%EmailAddress{value: value, position: 1}] = user.email_addresses
      assert value == "fred@example.com"
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(@create_user_attrs)
      assert %{email_addresses: [%{value: ["has already been taken"]}]} = errors_on(changeset)
    end

    test "unique slug is created - even when the full_name is not unique" do
      assert {:ok, %User{} = user} = Accounts.create_user(@create_user_attrs)
      assert user.slug =~ "fred.frederickson"
      assert String.length(user.slug) == 17
      attrs = Map.merge(@create_user_attrs, %{"email" => "fred.bloggs@example.com"})
      assert {:ok, %User{} = user} = Accounts.create_user(attrs)
      assert user.slug =~ "fred.frederickson"
      assert String.length(user.slug) == 26
    end

    test "invalid email returns email_addresses error" do
      attrs = Map.merge(@create_user_attrs, %{"email" => "invalid_email"})
      assert {:error, changeset} = Accounts.create_user(attrs)
      assert %{email_addresses: [%{value: ["has invalid format"]}]} = errors_on(changeset)
    end

    test "no full name returns error" do
      attrs = Map.merge(@create_user_attrs, %{"full_name" => ""})
      assert {:error, changeset} = Accounts.create_user(attrs)
      assert %{full_name: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "update user data" do
    test "update_user succeeds with valid data" do
      {:ok, user} = Accounts.create_user(@create_user_attrs)
      refute user.preferred_name
      attrs = %{"preferred_name" => "Eddie-baby"}
      assert {:ok, user} = Accounts.update_user(user, attrs)
      assert user.preferred_name =~ "Eddie-baby"
    end

    test "user can update slug" do
      %{slug: slug} = user = insert(:user)
      attrs = %{"slug" => String.replace(slug, ".", "-")}
      {:ok, %{slug: new_slug}} = Accounts.update_user(user, attrs)
      assert new_slug != slug
    end

    test "returns error when adding a duplicate slug" do
      %{slug: slug} = insert(:user)
      new_user = insert(:user)
      {:error, %Ecto.Changeset{} = changeset} = Accounts.update_user(new_user, %{"slug" => slug})
      assert %{slug: ["has already been taken"]} = errors_on(changeset)
    end

    test "update password changes the stored hash" do
      %{user_credential: %{password_hash: stored_hash} = user_credential} = insert(:user)
      attrs = %{password: "CN8W6kpb"}
      {:ok, %{password_hash: hash}} = Accounts.update_password(user_credential, attrs)
      assert hash != stored_hash
    end

    test "update_password with weak password fails" do
      %{user_credential: user_credential} = insert(:user)
      attrs = %{password: "password"}
      assert {:error, %Ecto.Changeset{}} = Accounts.update_password(user_credential, attrs)
    end
  end

  describe "delete user data" do
    setup [:create_user]

    test "delete_user/1 deletes the user and associated tables", %{user: user} do
      [email_address] = user.email_addresses
      assert Repo.get(EmailAddress, email_address.id)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      refute Accounts.get_user(%{"id" => user.id})
      refute Repo.get(EmailAddress, email_address.id)
    end
  end

  describe "user connections" do
    test "adds leaders / followers" do
      {:ok, %User{id: user_id} = user} = Accounts.create_user(@create_user_attrs)
      new_user_attrs = Map.merge(@create_user_attrs, %{"email" => "froderick@example.com"})
      {:ok, %User{id: new_user_id}} = Accounts.create_user(new_user_attrs)
      assert {:ok, %User{}} = Accounts.add_leaders(user, [new_user_id])

      assert user =
               %{"id" => user_id}
               |> Accounts.get_user()
               |> Accounts.with_associated_data([:followers, :leaders])

      assert user.followers == []
      assert [%User{id: ^new_user_id}] = user.leaders

      assert user =
               %{"id" => new_user_id}
               |> Accounts.get_user()
               |> Accounts.with_associated_data([:followers, :leaders])

      assert [%User{id: ^user_id}] = user.followers
      assert user.leaders == []
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

    test "list_email_addresses/2", %{user: user} do
      attrs = %{
        "is_public" => false,
        "description" => "secret email",
        "value" => "no_i_cant_tell_you@example.com"
      }

      Accounts.create_email_address(user, attrs)
      assert length(Accounts.list_email_addresses(user)) == 3
      assert length(Accounts.list_email_addresses(user, :public)) == 2
    end

    test "get_email_address returns a specific user's email_address", %{
      user: user,
      email_address: email_address
    } do
      assert Accounts.get_email_address(user, %{"id" => email_address.id}) == email_address
    end

    test "get_email_address returns returns nil for other user's email_address", %{
      email_address: email_address
    } do
      other = insert(:user)
      refute Accounts.get_email_address(other, %{"id" => email_address.id})
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
      user = Accounts.get_user(%{"id" => user.id})
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

    test "delete_email_address/1 deletes the email_address", %{
      email_address: email_address,
      user: user
    } do
      assert {:ok, %EmailAddress{}} = Accounts.delete_email_address(email_address)
      refute Accounts.get_email_address(user, %{"id" => email_address.id})
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

      assert Accounts.get_email_address(%{"value" => "froderick@example.com"})
      send(EmailManager, :check_expired)
      Process.sleep(10)
      refute Accounts.get_email_address(%{"value" => "froderick@example.com"})
    end

    test "unverified and verification not expired email is not deleted", %{user: user} do
      Accounts.create_email_address(user, %{"value" => "froderick@example.com"})
      assert Accounts.get_email_address(%{"value" => "froderick@example.com"})
      send(EmailManager, :check_expired)
      Process.sleep(10)
      assert Accounts.get_email_address(%{"value" => "froderick@example.com"})
    end

    test "verified email is not deleted", %{user: user} do
      expired_inserted_at = DateTime.add(DateTime.truncate(DateTime.utc_now(), :second), -2000)

      Repo.insert!(%EmailAddress{
        inserted_at: expired_inserted_at,
        value: "froderick@example.com",
        user_id: user.id,
        verified: true
      })

      assert Accounts.get_email_address(%{"value" => "froderick@example.com"})
      send(EmailManager, :check_expired)
      Process.sleep(10)
      assert Accounts.get_email_address(%{"value" => "froderick@example.com"})
    end
  end

  describe "read phone number data" do
    setup [:create_user, :create_phone_number]

    test "phone_number returns the phone_number with given id", %{
      phone_number: phone_number
    } do
      assert Accounts.get_phone_number(phone_number.id) == phone_number
    end

    test "change phone_number/1 returns a phone_number changeset", %{
      phone_number: phone_number
    } do
      assert %Ecto.Changeset{} = Accounts.change_phone_number(phone_number)
    end
  end

  describe "write phone_number data" do
    setup [:create_user]

    test "create_phone_number/1 with valid data creates a phone_number", %{user: user} do
      assert {:ok, %PhoneNumber{} = phone_number} =
               Accounts.create_phone_number(user, @valid_phone_attrs)

      assert phone_number.value == "+9123450292"
      assert phone_number.type == "mobile"
    end

    test "create_phone_number/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_phone_number(user, %{"value" => nil})
    end

    test "update phone_number with valid data updates the phone_number", %{user: user} do
      phone_number = insert(:phone_number, %{user: user})

      assert {:ok, %PhoneNumber{} = phone_number} =
               Accounts.update_phone_number(phone_number, @update_phone_attrs)

      assert phone_number.type == "work"
      assert phone_number.value == "02122229999"
    end

    test "update phone_number with invalid data returns error changeset", %{user: user} do
      phone_number = insert(:phone_number, %{user: user})

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_phone_number(phone_number, @invalid_phone_attrs)
    end
  end

  describe "delete phone_number data" do
    setup [:create_user, :create_phone_number]

    test "delete_phone_number/1 deletes the phone_number", %{phone_number: phone_number} do
      assert {:ok, %PhoneNumber{}} = Accounts.delete_phone_number(phone_number)
      refute Accounts.get_phone_number(phone_number.id)
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

  defp create_phone_number(%{user: user}) do
    {:ok, phone_number} = Accounts.create_phone_number(user, @valid_phone_attrs)
    {:ok, %{phone_number: phone_number}}
  end
end

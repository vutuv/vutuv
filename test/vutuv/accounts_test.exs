defmodule Vutuv.AccountsTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.{Accounts, Accounts.User, Accounts.Address, Devices, Devices.EmailAddress, Repo}

  @accept_language "en-ca,en;q=0.8,en-us;q=0.6,de-de;q=0.4,de;q=0.2"
  @create_user_attrs %{
    "email" => "fred@example.com",
    "password" => "reallyHard2gue$$",
    "accept_language" => @accept_language,
    "gender" => "male",
    "full_name" => "fred frederickson"
  }
  @create_address_attrs %{
    city: "London",
    country: "UK",
    description: "Home address",
    line_1: "221B",
    line_2: "Baker St",
    line_3: "Marylebone",
    line_4: "",
    state: "London",
    zip_code: "NW1 6XE"
  }

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

    test "get_user! returns the user with given slug", %{user: user} do
      user_1 = Accounts.get_user!(%{"slug" => user.slug})
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
      assert %{email_addresses: [%{value: ["duplicate"]}]} = errors_on(changeset)
      assert Devices.duplicate_email_error?(changeset)
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
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(%{"id" => user.id}) end
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
               |> Accounts.get_user!()
               |> Accounts.with_associated_data([:followers, :leaders])

      assert user.followers == []
      assert [%User{id: ^new_user_id}] = user.leaders

      assert user =
               %{"id" => new_user_id}
               |> Accounts.get_user!()
               |> Accounts.with_associated_data([:followers, :leaders])

      assert [%User{id: ^user_id}] = user.followers
      assert user.leaders == []
    end
  end

  describe "addresses" do
    test "list_addresses/1 returns all addresses" do
      address = insert(:address)
      [address_1] = Accounts.list_addresses(address.user)
      assert address.description == address_1.description
      assert address.city == address_1.city
      assert address.state == address_1.state
      assert address.country == address_1.country
    end

    test "get_address!/2 returns the address with given id" do
      address = insert(:address)
      address_1 = Accounts.get_address!(address.user, address.id)
      assert address.description == address_1.description
      assert address.city == address_1.city
      assert address.state == address_1.state
      assert address.country == address_1.country
    end

    test "create_address/2 with valid data creates a address" do
      user = insert(:user)
      assert {:ok, %Address{} = address} = Accounts.create_address(user, @create_address_attrs)
      assert address.city == "London"
      assert address.country == "UK"
      assert address.description == "Home address"
      assert address.line_1 == "221B"
      assert address.line_2 == "Baker St"
      assert address.line_3 == "Marylebone"
      assert address.state == "London"
      assert address.zip_code == "NW1 6XE"
    end

    test "create_address/2 with invalid data returns error changeset" do
      user = insert(:user)
      invalid_attrs = %{description: nil, country: nil}
      assert {:error, %Ecto.Changeset{}} = Accounts.create_address(user, invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = insert(:address, %{description: "Work address"})
      update_attrs = %{description: "Former work address"}
      assert {:ok, %Address{} = address} = Accounts.update_address(address, update_attrs)
      assert address.description =~ "Former work address"
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = insert(:address)
      assert address.description
      invalid_attrs = %{description: nil}
      assert {:error, %Ecto.Changeset{}} = Accounts.update_address(address, invalid_attrs)
      address = Accounts.get_address!(address.user, address.id)
      assert address.description
    end

    test "delete_address/1 deletes the address" do
      address = insert(:address)
      assert {:ok, %Address{}} = Accounts.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_address!(address.user, address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = insert(:address)
      assert %Ecto.Changeset{} = Accounts.change_address(address)
    end
  end

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(@create_user_attrs)
    {:ok, %{user: user}}
  end
end

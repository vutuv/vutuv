defmodule Vutuv.UserProfilesTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.{
    UserProfiles,
    UserProfiles.User,
    UserProfiles.Address,
    Devices,
    Devices.EmailAddress,
    Repo
  }

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
      [user_1] = UserProfiles.list_users()
      assert user_1.id == user.id
      assert user_1.full_name == user.full_name
      assert length(UserProfiles.list_users()) == 1
      insert(:user)
      assert length(UserProfiles.list_users()) == 2
    end

    test "paginate_users/1 returns the users in a paginated struct", %{user: user} do
      %Scrivener.Page{entries: [user_1]} = UserProfiles.paginate_users(%{})
      assert user_1.id == user.id
      assert user_1.full_name == user.full_name
      assert %Scrivener.Page{total_entries: 1} = UserProfiles.paginate_users(%{})
      insert(:user)
      assert %Scrivener.Page{total_entries: 2} = UserProfiles.paginate_users(%{})
    end

    test "get_user! returns the user with given slug", %{user: user} do
      user_1 = UserProfiles.get_user!(%{"slug" => user.slug})
      assert user_1.id == user.id
      assert user_1.full_name == user.full_name
      assert user_1.gender == user.gender
      refute Ecto.assoc_loaded?(user_1.user_credential)
    end

    test "change_user/1 returns a user changeset", %{user: user} do
      assert %Ecto.Changeset{} = UserProfiles.change_user(user)
    end

    test "get_user_overview returns user with associations", %{user: user} do
      user = add_user_assocs(user)
      assert [email_address] = user.email_addresses
      assert length(user.followees) == 3
      assert length(user.followers) == 3

      for user <- user.followees do
        assert Ecto.assoc_loaded?(user.followee)
        refute Ecto.assoc_loaded?(user.follower)
      end

      for user <- user.followers do
        refute Ecto.assoc_loaded?(user.followee)
        assert Ecto.assoc_loaded?(user.follower)
      end

      assert [user_tag] = user.user_tags
      assert length(user_tag.user_tag_endorsements) == 6
    end
  end

  describe "create user data" do
    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = UserProfiles.create_user(@create_user_attrs)
      assert user.accept_language == @accept_language
      assert user.gender == "male"
      assert user.locale == "en_CA"
      assert [%EmailAddress{value: value, position: 1}] = user.email_addresses
      assert value == "fred@example.com"
    end

    test "noindex is correctly set in create_user/1" do
      assert {:ok, %User{} = user} = UserProfiles.create_user(@create_user_attrs)
      assert user.noindex == false

      attrs =
        Map.merge(@create_user_attrs, %{"email" => "froderick@example.com", "noindex" => true})

      assert {:ok, %User{} = user} = UserProfiles.create_user(attrs)
      assert user.noindex == true
    end

    test "subscribe_emails is correctly set in create_user/1" do
      assert {:ok, %User{} = user} = UserProfiles.create_user(@create_user_attrs)
      assert user.subscribe_emails == true

      attrs =
        Map.merge(@create_user_attrs, %{
          "email" => "froderick@example.com",
          "subscribe_emails" => false
        })

      assert {:ok, %User{} = user} = UserProfiles.create_user(attrs)
      assert user.subscribe_emails == false
    end

    test "create_user/1 with invalid data returns error changeset" do
      invalid_attrs = Map.merge(@create_user_attrs, %{"email" => ""})
      assert {:error, %Ecto.Changeset{} = changeset} = UserProfiles.create_user(invalid_attrs)
      assert %{email_addresses: [%{value: ["can't be blank"]}]} = errors_on(changeset)
      invalid_attrs = Map.merge(@create_user_attrs, %{"password" => nil})
      assert {:error, %Ecto.Changeset{} = changeset} = UserProfiles.create_user(invalid_attrs)
      assert %{user_credential: %{password: ["can't be blank"]}} = errors_on(changeset)
    end

    test "returns error when adding a duplicate email" do
      assert {:ok, %User{} = user} = UserProfiles.create_user(@create_user_attrs)
      assert [%EmailAddress{value: value, position: 1}] = user.email_addresses
      assert value == "fred@example.com"

      assert {:error, %Ecto.Changeset{} = changeset} =
               UserProfiles.create_user(@create_user_attrs)

      assert %{email_addresses: [%{value: ["duplicate"]}]} = errors_on(changeset)
      assert Devices.duplicate_email_error?(changeset)
    end

    test "unique slug is created - even when the full_name is not unique" do
      assert {:ok, %User{} = user} = UserProfiles.create_user(@create_user_attrs)
      assert user.slug =~ "fred.frederickson"
      assert String.length(user.slug) == 17
      attrs = Map.merge(@create_user_attrs, %{"email" => "fred.bloggs@example.com"})
      assert {:ok, %User{} = user} = UserProfiles.create_user(attrs)
      assert user.slug =~ "fred.frederickson"
      assert String.length(user.slug) == 26
    end

    test "invalid email returns email_addresses error" do
      attrs = Map.merge(@create_user_attrs, %{"email" => "invalid_email"})
      assert {:error, changeset} = UserProfiles.create_user(attrs)
      assert %{email_addresses: [%{value: ["has invalid format"]}]} = errors_on(changeset)
    end

    test "no full name returns error" do
      attrs = Map.merge(@create_user_attrs, %{"full_name" => ""})
      assert {:error, changeset} = UserProfiles.create_user(attrs)
      assert %{full_name: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "update user data" do
    test "update_user succeeds with valid data" do
      {:ok, user} = UserProfiles.create_user(@create_user_attrs)
      refute user.preferred_name
      attrs = %{"preferred_name" => "Eddie-baby"}
      assert {:ok, user} = UserProfiles.update_user(user, attrs)
      assert user.preferred_name =~ "Eddie-baby"
    end

    test "user update slug" do
      %{slug: slug} = user = insert(:user)
      attrs = %{"slug" => String.replace(slug, ".", "-")}
      {:ok, %{slug: new_slug}} = UserProfiles.update_user(user, attrs)
      assert new_slug != slug
    end

    test "returns error when adding a duplicate slug" do
      %{slug: slug} = insert(:user)
      new_user = insert(:user)

      {:error, %Ecto.Changeset{} = changeset} =
        UserProfiles.update_user(new_user, %{"slug" => slug})

      assert %{slug: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "delete user data" do
    setup [:create_user]

    test "delete_user/1 deletes the user and associated tables", %{user: user} do
      [email_address] = user.email_addresses
      assert Repo.get(EmailAddress, email_address.id)
      assert {:ok, %User{}} = UserProfiles.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> UserProfiles.get_user!(%{"id" => user.id}) end
      refute Repo.get(EmailAddress, email_address.id)
    end
  end

  describe "addresses" do
    test "list_addresses/1 returns all addresses" do
      %Address{user: user} = address = insert(:address)
      [address_1] = UserProfiles.list_addresses(user)
      assert address_1.description == address.description
      assert address_1.city == address.city
      assert address_1.state == address.state
      assert address_1.country == address.country
    end

    test "get_address!/2 returns the address with given id" do
      %Address{id: id, user: user} = address = insert(:address)
      address_1 = UserProfiles.get_address!(user, id)
      assert address_1.description == address.description
      assert address_1.city == address.city
      assert address_1.state == address.state
      assert address_1.country == address.country
    end

    test "create_address/2 with valid data creates a address" do
      user = insert(:user)

      assert {:ok, %Address{} = address} =
               UserProfiles.create_address(user, @create_address_attrs)

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
      assert {:error, %Ecto.Changeset{}} = UserProfiles.create_address(user, invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = insert(:address, %{description: "Work address"})
      update_attrs = %{description: "Former work address"}
      assert {:ok, %Address{} = address} = UserProfiles.update_address(address, update_attrs)
      assert address.description =~ "Former work address"
    end

    test "update_address/2 with invalid data returns error changeset" do
      %Address{id: id, user: user} = address = insert(:address)
      assert address.description
      invalid_attrs = %{description: nil}
      assert {:error, %Ecto.Changeset{}} = UserProfiles.update_address(address, invalid_attrs)
      address = UserProfiles.get_address!(user, id)
      assert address.description
    end

    test "delete_address/1 deletes the address" do
      %Address{id: id, user: user} = address = insert(:address)
      assert {:ok, %Address{}} = UserProfiles.delete_address(address)

      assert_raise Ecto.NoResultsError, fn ->
        UserProfiles.get_address!(user, id)
      end
    end

    test "change_address/1 returns a address changeset" do
      address = insert(:address)
      assert %Ecto.Changeset{} = UserProfiles.change_address(address)
    end
  end

  defp create_user(_) do
    {:ok, user} = UserProfiles.create_user(@create_user_attrs)
    {:ok, %{user: user}}
  end
end

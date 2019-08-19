defmodule Vutuv.SocialNetworksTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.{SocialNetworks, SocialNetworks.SocialMediaAccount}

  @create_social_media_account_attrs %{provider: "Facebook", value: "arrr"}

  describe "social_media_accounts" do
    test "list_social_media_accounts/1 returns all social_media_accounts" do
      %SocialMediaAccount{user: user} = account = insert(:social_media_account)
      [account_1] = SocialNetworks.list_social_media_accounts(user)
      assert account_1.provider == account.provider
      assert account_1.value == account.value
    end

    test "get_social_media_account!/2 returns the social media account with given id" do
      %SocialMediaAccount{id: id, user: user} = account = insert(:social_media_account)
      account_1 = SocialNetworks.get_social_media_account!(user, id)
      assert account_1.provider == account.provider
      assert account_1.value == account.value
    end

    test "create_social_media_account/2 with valid data creates a social media account" do
      user = insert(:user)

      assert {:ok, %SocialMediaAccount{} = account} =
               SocialNetworks.create_social_media_account(
                 user,
                 @create_social_media_account_attrs
               )

      assert account.provider == "Facebook"
      assert account.value == "arrr"
    end

    test "can use full url for value with create_social_media_account/2" do
      user = insert(:user)
      attrs = %{provider: "Facebook", value: "https://www.facebook.com/arrr"}

      assert {:ok, %SocialMediaAccount{} = account} =
               SocialNetworks.create_social_media_account(user, attrs)

      assert account.provider == "Facebook"
      assert account.value == "arrr"
    end

    test "create_social_media_account/2 with invalid provider returns error changeset" do
      user = insert(:user)
      invalid_attrs = %{provider: "Pony Express", value: "arrr"}

      assert {:error, %Ecto.Changeset{} = changeset} =
               SocialNetworks.create_social_media_account(user, invalid_attrs)

      assert %{provider: ["is invalid"]} = errors_on(changeset)
    end

    test "create_social_media_account/2 with invalid format for value returns error changeset" do
      user = insert(:user)
      invalid_attrs = %{provider: "Facebook", value: "not right format"}

      assert {:error, %Ecto.Changeset{} = changeset} =
               SocialNetworks.create_social_media_account(user, invalid_attrs)

      assert %{value: ["has invalid format"]} = errors_on(changeset)
    end

    test "update_social_media_account/2 with valid data updates the social media account" do
      account = insert(:social_media_account)

      assert {:ok, %SocialMediaAccount{} = account} =
               SocialNetworks.update_social_media_account(account, %{value: "avast"})

      assert account.value == "avast"
    end

    test "update_social_media_account/2 with invalid data returns error changeset" do
      %SocialMediaAccount{id: id, user: user} = account = insert(:social_media_account)

      assert {:error, %Ecto.Changeset{}} =
               SocialNetworks.update_social_media_account(account, %{provider: "Cup and string"})

      account_1 = SocialNetworks.get_social_media_account!(user, id)
      assert account.provider == account_1.provider
      assert account_1.provider != "Cup and string"
    end

    test "delete_social_media_account/1 deletes the social media account" do
      %SocialMediaAccount{id: id, user: user} = account = insert(:social_media_account)
      assert {:ok, %SocialMediaAccount{}} = SocialNetworks.delete_social_media_account(account)

      assert_raise Ecto.NoResultsError, fn ->
        SocialNetworks.get_social_media_account!(user, id)
      end
    end

    test "change_social_media_account/1 returns a social media account changeset" do
      account = insert(:social_media_account)
      assert %Ecto.Changeset{} = SocialNetworks.change_social_media_account(account)
    end
  end
end

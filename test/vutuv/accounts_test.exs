defmodule Vutuv.AccountsTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.Accounts

  describe "update password" do
    test "changes the stored hash" do
      %{user_credential: %{password_hash: stored_hash} = user_credential} = insert(:user)
      attrs = %{password: "CN8W6kpb"}
      assert {:ok, %{password_hash: hash}} = Accounts.update_password(user_credential, attrs)
      assert hash != stored_hash
    end

    test "weak password fails" do
      %{user_credential: user_credential} = insert(:user)
      attrs = %{password: "password"}
      assert {:error, %Ecto.Changeset{}} = Accounts.update_password(user_credential, attrs)
    end
  end

  describe "set admin rights" do
    test "is_admin is false by default" do
      %{user_credential: user_credential} = insert(:user)
      assert user_credential.is_admin == false
    end

    test "can set is_admin" do
      %{user_credential: user_credential} = insert(:user)
      assert user_credential.is_admin == false

      assert {:ok, %{is_admin: true} = user_credential} =
               Accounts.set_admin(user_credential, %{is_admin: true})

      assert {:ok, %{is_admin: false}} = Accounts.set_admin(user_credential, %{is_admin: false})
    end
  end
end

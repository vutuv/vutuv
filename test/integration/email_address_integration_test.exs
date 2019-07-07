defmodule VutuvWeb.EmailAddressIntegrationTest do
  use Vutuv.DataCase

  import VutuvWeb.AuthTestHelpers
  import VutuvWeb.IntegrationHelper

  alias Vutuv.{Accounts, Accounts.User}

  @create_attrs %{
    "is_public" => true,
    "description" => "backup email",
    "value" => "abcdef@example.com"
  }

  setup do
    user = add_user_confirmed("ted@mail.com")
    %{"access_token" => token} = login_user("ted@mail.com")
    {:ok, %{user: user, token: token}}
  end

  describe "read email_address data" do
    test "list email_addresses", %{user: user, token: token} do
      {:ok, response} =
        token |> authenticated_client() |> Tesla.get("/users/#{user.slug}/email_addresses")

      assert %Tesla.Env{body: %{"data" => data}, status: 200} = response
      assert length(data) == 1
    end

    test "show specific email_address data", %{user: user, token: token} do
      %User{email_addresses: [%{id: id}]} = user

      {:ok, response} =
        token |> authenticated_client() |> Tesla.get("/users/#{user.slug}/email_addresses/#{id}")

      assert %Tesla.Env{body: %{"data" => data}, status: 200} = response
      assert data["id"] == id
    end
  end

  describe "write / update email_address data" do
    test "create email_address", %{user: user, token: token} do
      {:ok, response} =
        token
        |> authenticated_client()
        |> Tesla.post("/users/#{user.slug}/email_addresses", %{email_address: @create_attrs})

      assert %Tesla.Env{body: %{"data" => data}, status: 201} = response
      assert data["user_id"] == user.id
      assert data["value"] == @create_attrs["value"]
    end

    test "invalid data errors when creating email_address", %{user: user, token: token} do
      {:ok, response} =
        token
        |> authenticated_client()
        |> Tesla.post("/users/#{user.slug}/email_addresses", %{email_address: %{"value" => ""}})

      assert %Tesla.Env{body: %{"errors" => errors}, status: 422} = response
      assert errors["value"] == ["can't be blank"]
    end

    test "update email_address", %{user: user, token: token} do
      %User{email_addresses: [%{id: id, is_public: true}]} = user

      {:ok, response} =
        token
        |> authenticated_client()
        |> Tesla.put("/users/#{user.slug}/email_addresses/#{id}", %{
          email_address: %{"is_public" => false}
        })

      assert %Tesla.Env{body: %{"data" => data}, status: 200} = response
      assert data["user_id"] == user.id
      email_address = Accounts.get_email_address(id)
      assert email_address.is_public == false
    end

    test "invalid data errors when updating email_address", %{user: user, token: token} do
      too_long = String.duplicate("too long", 32)
      %User{email_addresses: [%{id: id, is_public: true}]} = user

      {:ok, response} =
        token
        |> authenticated_client()
        |> Tesla.put("/users/#{user.slug}/email_addresses/#{id}", %{
          email_address: %{"description" => too_long}
        })

      assert %Tesla.Env{body: %{"errors" => errors}, status: 422} = response
      assert errors["description"] == ["should be at most 255 character(s)"]
    end
  end

  describe "delete email_address" do
    test "delete email_address", %{user: user, token: token} do
      %User{email_addresses: [%{id: id}]} = user

      {:ok, response} =
        token
        |> authenticated_client()
        |> Tesla.delete("/users/#{user.slug}/email_addresses/#{id}")

      assert %Tesla.Env{body: "", status: 204} = response
      refute Accounts.get_email_address(id)
    end

    test "cannot delete other email_address", %{user: user, token: token} do
      %User{email_addresses: [%{id: id}]} = other = add_user_confirmed("raymond@example.com")

      {:ok, response} =
        token
        |> authenticated_client()
        |> Tesla.delete("/users/#{user.slug}/email_addresses/#{id}")

      assert %Tesla.Env{body: %{"errors" => errors}, status: 403} = response
      assert errors["detail"] =~ "You are not authorized"
      assert Accounts.get_email_address(id)

      {:ok, response} =
        token
        |> authenticated_client()
        |> Tesla.delete("/users/#{other.slug}/email_addresses/#{id}")

      assert %Tesla.Env{body: %{"errors" => errors}, status: 403} = response
      assert errors["detail"] =~ "You are not authorized"
      assert Accounts.get_email_address(id)
    end
  end
end

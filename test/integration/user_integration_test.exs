defmodule VutuvWeb.UserIntegrationTest do
  use Vutuv.DataCase

  import VutuvWeb.AuthTestHelpers
  import VutuvWeb.IntegrationHelper

  alias Vutuv.UserProfiles

  @create_attrs %{
    "email" => "bill@example.com",
    "password" => "reallyHard2gue$$",
    "gender" => "male",
    "full_name" => "bill shakespeare"
  }

  setup do
    user = add_user_confirmed("ted@mail.com")
    %{"access_token" => token} = login_user("ted@mail.com")
    {:ok, %{user: user, token: token}}
  end

  describe "read user data" do
    test "list users" do
      {:ok, response} = Tesla.get(simple_client(), "/users")
      assert %Tesla.Env{body: %{"data" => data}, status: 200} = response
      assert length(data) == 1
    end

    test "show specific user data", %{user: %{slug: slug} = user} do
      {:ok, response} = Tesla.get(simple_client(), "/users/#{slug}")
      assert %Tesla.Env{body: %{"data" => data}, status: 200} = response
      assert data["full_name"] == user.full_name
    end
  end

  describe "write / update user data" do
    test "create user" do
      {:ok, response} = Tesla.post(simple_client(), "/users", %{user: @create_attrs})
      assert %Tesla.Env{body: %{"data" => data}, status: 201} = response
      assert data["id"]
      assert UserProfiles.get_user!(%{"email" => @create_attrs["email"]})
    end

    test "invalid data errors when creating user" do
      {:ok, response} = Tesla.post(simple_client(), "/users", %{user: %{"email" => nil}})
      assert %Tesla.Env{body: %{"errors" => errors}, status: 422} = response
      assert errors["full_name"] == ["can't be blank"]
    end

    test "update user", %{user: user, token: token} do
      attrs = %{"full_name" => "Raymond Luxury Yacht"}

      {:ok, response} =
        token |> authenticated_client() |> Tesla.put("/users/#{user.slug}", %{user: attrs})

      assert %Tesla.Env{body: %{"data" => data}, status: 200} = response
      assert data["id"] == user.id
      updated_user = UserProfiles.get_user!(%{"id" => user.id})
      assert updated_user.full_name == "Raymond Luxury Yacht"
    end

    test "invalid data errors when updating user", %{user: user, token: token} do
      attrs = %{"honorific_prefix" => String.duplicate("Dr", 42)}

      {:ok, response} =
        token |> authenticated_client() |> Tesla.put("/users/#{user.slug}", %{user: attrs})

      assert %Tesla.Env{body: %{"errors" => errors}, status: 422} = response
      assert errors["honorific_prefix"] == ["should be at most 80 character(s)"]
    end
  end

  describe "delete user" do
    test "delete user", %{user: user, token: token} do
      {:ok, response} = token |> authenticated_client() |> Tesla.delete("/users/#{user.slug}")
      assert %Tesla.Env{body: "", status: 204} = response
      assert_raise Ecto.NoResultsError, fn -> UserProfiles.get_user!(%{"id" => user.id}) end
    end

    test "cannot delete other user", %{token: token} do
      other = add_user_confirmed("tony@example.com")
      {:ok, response} = token |> authenticated_client() |> Tesla.delete("/users/#{other.slug}")
      assert %Tesla.Env{body: %{"errors" => errors}, status: 403} = response
      assert errors["detail"] =~ "You are not authorized"
      assert UserProfiles.get_user!(%{"id" => other.id})
    end
  end
end

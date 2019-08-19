defmodule Vutuv.PublicationsTest do
  use Vutuv.DataCase

  import Vutuv.Factory
  import VutuvWeb.AuthTestHelpers

  alias Vutuv.{UserProfiles, Publications, Publications.Post}

  @create_post_attrs %{
    body: Faker.Company.bs(),
    title: Faker.Company.name(),
    visibility_level: "private"
  }
  @update_post_attrs %{
    body: Faker.Company.bs(),
    title: Faker.Company.name(),
    visibility_level: "public"
  }
  @invalid_attrs %{body: nil, title: nil}

  describe "list / get posts" do
    setup [:add_posts]

    test "list_posts/0 returns all posts" do
      assert length(Publications.list_posts()) == 5
    end

    test "list_posts/1 returns all of a user's posts", %{user: user} do
      assert length(Publications.list_posts(user)) == 4
    end

    test "list_posts/2 returns a user's posts depending on the visibility_level", %{user: user} do
      other = add_user("igor@example.com")
      UserProfiles.add_leaders(other, [user.id])
      assert length(Publications.list_posts(user, other)) == 3
      assert length(Publications.list_posts(user, nil)) == 2
    end

    test "get_post!/2 returns a user's post with given id" do
      %Post{id: post_id, title: title, body: body, user_id: user_id} = insert(:post)
      user = UserProfiles.get_user!(%{"id" => user_id})
      post = Publications.get_post!(user, post_id)
      assert post.title == title
      assert post.body == body
      assert post.user_id == user_id
    end
  end

  describe "create / update posts" do
    test "create_post/2 with valid data creates a post" do
      user = add_user("froderick@mail.com")
      assert {:ok, %Post{} = post} = Publications.create_post(user, @create_post_attrs)
      assert post.body == @create_post_attrs[:body]
      assert post.published_at == DateTime.truncate(DateTime.utc_now(), :second)
      assert post.title == @create_post_attrs[:title]
      assert post.visibility_level == "private"
    end

    test "create_post/2 with just required attrs" do
      attrs = %{body: Faker.Lorem.Shakespeare.romeo_and_juliet(), title: Faker.Company.name()}
      user = add_user("froderick@mail.com")
      assert {:ok, %Post{} = post} = Publications.create_post(user, attrs)
      assert post.body == attrs[:body]
      assert post.published_at == DateTime.truncate(DateTime.utc_now(), :second)
      assert post.title == attrs[:title]
      assert post.visibility_level == "private"
    end

    test "create_post/2 with invalid data returns error changeset" do
      user = add_user("froderick@mail.com")
      assert {:error, %Ecto.Changeset{}} = Publications.create_post(user, @invalid_attrs)
    end

    test "create_post/2 with invalid visibility_level returns error changeset" do
      attrs = Map.merge(@create_post_attrs, %{visibility_level: "anyone really"})
      user = add_user("froderick@mail.com")
      assert {:error, %Ecto.Changeset{} = changeset} = Publications.create_post(user, attrs)
      assert %{visibility_level: ["is invalid"]} = errors_on(changeset)
    end

    test "update_post/2 with valid data updates the post" do
      post = insert(:post)
      assert {:ok, %Post{} = post} = Publications.update_post(post, @update_post_attrs)
      assert post.body == @update_post_attrs[:body]
      assert post.title == @update_post_attrs[:title]
      assert post.visibility_level == "public"
    end

    test "update_post/2 does not update published_at" do
      published_at = DateTime.truncate(Faker.DateTime.backward(1), :second)
      post = insert(:post, %{published_at: published_at})

      assert {:ok, %Post{published_at: published_at} = post} =
               Publications.update_post(post, @update_post_attrs)

      assert post.published_at == published_at
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = insert(:post)
      assert {:error, %Ecto.Changeset{}} = Publications.update_post(post, @invalid_attrs)
    end
  end

  describe "delete posts" do
    test "delete_post/1 deletes the post" do
      post = insert(:post)
      assert {:ok, %Post{}} = Publications.delete_post(post)
      user = UserProfiles.get_user!(%{"id" => post.user_id})
      assert_raise Ecto.NoResultsError, fn -> Publications.get_post!(user, post.id) end
    end
  end

  defp add_posts(_) do
    user = add_user("froderick@mail.com")
    _posts = insert_list(2, :post, %{user: user, visibility_level: "public"})
    _post = insert(:post, %{user: user, visibility_level: "followers"})
    _post = insert(:post, %{user: user})
    _post = insert(:post)
    {:ok, %{user: user}}
  end
end

defmodule Vutuv.SocialsTest do
  use Vutuv.DataCase

  import Vutuv.Factory
  import VutuvWeb.AuthTestHelpers

  alias Vutuv.{Socials, Socials.Post}

  @valid_attrs %{
    body: Faker.Company.bs(),
    title: Faker.Company.name(),
    visibility_level: "private"
  }
  @update_attrs %{
    body: Faker.Company.bs(),
    title: Faker.Company.name(),
    visibility_level: "public"
  }
  @invalid_attrs %{body: nil, title: nil}

  describe "list / get posts" do
    setup [:add_posts]

    test "list_posts/0 returns all posts" do
      assert length(Socials.list_posts()) == 3
    end

    test "list_posts/1 returns all of a user's posts", %{user: user} do
      assert length(Socials.list_posts(user)) == 2
    end

    test "get_post/1 returns the post with given id" do
      %Post{id: post_id, title: title, body: body, user_id: user_id} = insert(:post)
      post = Socials.get_post(post_id)
      assert post.title == title
      assert post.body == body
      assert post.user_id == user_id
    end
  end

  describe "create / update posts" do
    test "create_post/2 with valid data creates a post" do
      user = add_user("froderick@mail.com")
      assert {:ok, %Post{} = post} = Socials.create_post(user, @valid_attrs)
      assert post.body == @valid_attrs[:body]
      assert post.published_at == DateTime.truncate(DateTime.utc_now(), :second)
      assert post.title == @valid_attrs[:title]
      assert post.visibility_level == "private"
    end

    test "create_post/2 with just required attrs" do
      attrs = %{body: "some body", title: "some title"}
      user = add_user("froderick@mail.com")
      assert {:ok, %Post{} = post} = Socials.create_post(user, attrs)
      assert post.body == "some body"
      assert post.published_at == DateTime.truncate(DateTime.utc_now(), :second)
      assert post.title == "some title"
      assert post.visibility_level == "private"
    end

    test "create_post/2 with invalid data returns error changeset" do
      user = add_user("froderick@mail.com")
      assert {:error, %Ecto.Changeset{}} = Socials.create_post(user, @invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = insert(:post)
      assert {:ok, %Post{} = post} = Socials.update_post(post, @update_attrs)
      assert post.body == @update_attrs[:body]
      assert post.title == @update_attrs[:title]
      assert post.visibility_level == "public"
    end

    test "update_post/2 does not update published_at" do
      published_at = DateTime.truncate(Faker.DateTime.backward(1), :second)
      post = insert(:post, %{published_at: published_at})

      assert {:ok, %Post{published_at: published_at} = post} =
               Socials.update_post(post, @update_attrs)

      assert post.published_at == published_at
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = insert(:post)
      assert {:error, %Ecto.Changeset{}} = Socials.update_post(post, @invalid_attrs)
    end
  end

  describe "delete posts" do
    test "delete_post/1 deletes the post" do
      post = insert(:post)
      assert {:ok, %Post{}} = Socials.delete_post(post)
      refute Socials.get_post(post.id)
    end
  end

  defp add_posts(_) do
    user = add_user("froderick@mail.com")
    _posts = insert_list(2, :post, %{user: user})
    _post = insert(:post)
    {:ok, %{user: user}}
  end
end

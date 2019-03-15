defmodule Vutuv.SocialsTest do
  use Vutuv.DataCase

  alias Vutuv.Socials

  describe "posts" do
    alias Vutuv.Socials.Post

    @valid_attrs %{
      body: "some body",
      page_info_cache: "some page_info_cache",
      published_at: "2010-04-17T14:00:00Z",
      title: "some title",
      visibility_level: "some visibility_level"
    }
    @update_attrs %{
      body: "some updated body",
      page_info_cache: "some updated page_info_cache",
      published_at: "2011-05-18T15:01:01Z",
      title: "some updated title",
      visibility_level: "some updated visibility_level"
    }
    @invalid_attrs %{
      body: nil,
      page_info_cache: nil,
      published_at: nil,
      title: nil,
      visibility_level: nil
    }

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Socials.create_post()

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Socials.list_posts() == [post]
    end

    test "get_post/1 returns the post with given id" do
      post = post_fixture()
      assert Socials.get_post(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Socials.create_post(@valid_attrs)
      assert post.body == "some body"
      assert post.page_info_cache == "some page_info_cache"
      assert post.published_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert post.title == "some title"
      assert post.visibility_level == "some visibility_level"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Socials.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Socials.update_post(post, @update_attrs)
      assert post.body == "some updated body"
      assert post.page_info_cache == "some updated page_info_cache"
      assert post.published_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert post.title == "some updated title"
      assert post.visibility_level == "some updated visibility_level"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Socials.update_post(post, @invalid_attrs)
      assert post == Socials.get_post(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Socials.delete_post(post)
      refute Socials.get_post(post.id)
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Socials.change_post(post)
    end
  end
end

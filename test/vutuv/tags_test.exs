defmodule Vutuv.TagsTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.{Publications, Repo, Tags, Tags.Tag, Tags.UserTag, Tags.UserTagEndorsement}

  @create_tag_attrs %{
    "description" => "JavaScript expertise",
    "name" => "JavaScript",
    "url" => "http://some-url.com"
  }
  @update_tag_attrs %{
    "description" => "Logic programming will save the world",
    "name" => "Prolog",
    "url" => "http://some-updated-url.com"
  }
  @invalid_attrs %{"description" => nil, "name" => nil, "url" => nil}

  describe "tags" do
    test "list_tags/0 returns all tags" do
      tag = insert(:tag)
      assert Tags.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = insert(:tag)
      assert Tags.get_tag!(tag.id) == tag
    end

    test "create_or_get_tag/1 creates a tag or gets an existing tag" do
      assert {:ok, %Tag{} = tag} = Tags.create_or_get_tag(@create_tag_attrs)
      assert tag.description =~ "JavaScript expertise"
      assert tag.name == "JavaScript"
      assert tag.url == "http://some-url.com"
      assert {:ok, %Tag{} = tag_1} = Tags.create_or_get_tag(@create_tag_attrs)
      assert tag.id == tag_1.id
      assert tag_1.name == "JavaScript"
    end

    test "create_or_get_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tags.create_or_get_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = insert(:tag)
      assert {:ok, %Tag{} = tag} = Tags.update_tag(tag, @update_tag_attrs)
      assert tag.description =~ "Logic programming"
      assert tag.name == "Prolog"
      assert tag.url == "http://some-updated-url.com"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = insert(:tag)
      assert {:error, %Ecto.Changeset{}} = Tags.update_tag(tag, @invalid_attrs)
      assert tag == Tags.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = insert(:tag)
      assert {:ok, %Tag{}} = Tags.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Tags.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = insert(:tag)
      assert %Ecto.Changeset{} = Tags.change_tag(tag)
    end
  end

  describe "user tags" do
    test "list_user_tags returns a user's user_tags" do
      %UserTag{id: id, user: user} = insert(:user_tag)
      [user_tag_1] = Tags.list_user_tags(user)
      assert user_tag_1.id == id
      assert user_tag_1.user_id == user.id
    end

    test "get_user_tag! returns user_tag and tag" do
      %UserTag{id: id, user: user} = insert(:user_tag)
      user_tag_1 = Tags.get_user_tag!(user, id)
      assert user_tag_1.id == id
      assert user_tag_1.user_id == user.id
      assert user_tag_1.tag.name
    end

    test "create_user_tag creates a user_tag" do
      user = insert(:user)
      {:ok, user_tag} = Tags.create_user_tag(user, @create_tag_attrs)
      assert user_tag.user_id == user.id
    end

    test "delete_user_tag deletes own user's user_tag" do
      %UserTag{id: id, user: user} = user_tag = insert(:user_tag)
      {:ok, _user_tag} = Tags.delete_user_tag(user_tag)
      assert_raise Ecto.NoResultsError, fn -> Tags.get_user_tag!(user, id) end
    end
  end

  describe "post tags" do
    test "association can be created between a post and tags" do
      post = insert(:post)
      {:ok, %Tag{} = tag} = Tags.create_or_get_tag(@create_tag_attrs)
      {:ok, post} = Publications.add_post_tags(post, [tag.id])
      assert [%Tag{} = ^tag] = post.tags
      %Tag{posts: [post_1]} = Tags.get_tag!(tag.id) |> Repo.preload(:posts)
      assert post.id == post_1.id
    end
  end

  describe "user_tag_endorsements" do
    setup [:create_user_tag]

    test "create_user_tag_endorsement/2 with valid data creates a user_tag_endorsement", %{
      user_tag: user_tag
    } do
      user = insert(:user)
      attrs = %{"user_tag_id" => user_tag.id}

      assert {:ok, %UserTagEndorsement{} = user_tag_endorsement} =
               Tags.create_user_tag_endorsement(user, attrs)
    end

    test "same user cannot endorse tag more than once", %{user_tag: user_tag} do
      user = insert(:user)
      attrs = %{"user_tag_id" => user_tag.id}

      assert {:ok, %UserTagEndorsement{} = user_tag_endorsement} =
               Tags.create_user_tag_endorsement(user, attrs)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Tags.create_user_tag_endorsement(user, attrs)

      assert %{user_id: ["has already been taken"]} = errors_on(changeset)
    end

    test "count user_tag_endorsements" do
      user = insert(:user)
      {:ok, user_tag} = Tags.create_user_tag(user, @create_tag_attrs)
      endorser = insert(:user)
      assert Tags.user_tag_endorsements_count(user_tag) == 0
      attrs = %{"user_tag_id" => user_tag.id, "user_id" => endorser.id}

      assert {:ok, %UserTagEndorsement{} = user_tag_endorsement} =
               Tags.create_user_tag_endorsement(user, attrs)

      assert Tags.user_tag_endorsements_count(user_tag) == 1
    end

    test "delete_user_tag_endorsement/1 deletes the user_tag_endorsement", %{user_tag: user_tag} do
      user = insert(:user)
      attrs = %{"user_tag_id" => user_tag.id, "user_id" => user.id}

      {:ok, %UserTagEndorsement{} = user_tag_endorsement} =
        Tags.create_user_tag_endorsement(user, attrs)

      assert {:ok, %UserTagEndorsement{}} = Tags.delete_user_tag_endorsement(user_tag_endorsement)

      assert_raise Ecto.NoResultsError, fn ->
        Repo.get!(UserTagEndorsement, user_tag_endorsement.id)
      end
    end
  end

  defp create_user_tag(_) do
    user = insert(:user)
    {:ok, user_tag} = Tags.create_user_tag(user, @create_tag_attrs)
    {:ok, %{user_tag: user_tag}}
  end
end

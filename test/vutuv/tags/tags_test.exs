defmodule Vutuv.TagsTest do
  use Vutuv.DataCase

  alias Vutuv.{Tags, Tags.Tag}

  describe "tags" do
    @valid_attrs %{
      "description" => "some description",
      "name" => "Some name",
      "url" => "http://some-url.com"
    }
    @update_attrs %{
      "description" => "some updated description",
      "name" => "Some updated name",
      "url" => "http://some-updated-url.com"
    }
    @invalid_attrs %{"description" => nil, "name" => nil, "url" => nil}

    def tag_fixture(attrs \\ %{}) do
      {:ok, tag} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tags.create_tag()

      tag
    end

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Tags.list_tags() == [tag]
    end

    test "get_tag/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Tags.get_tag(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      assert {:ok, %Tag{} = tag} = Tags.create_tag(@valid_attrs)
      assert tag.description == "some description"
      assert tag.name == "Some name"
      assert tag.url == "http://some-url.com"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tags.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{} = tag} = Tags.update_tag(tag, @update_attrs)
      assert tag.description == "some updated description"
      assert tag.name == "Some updated name"
      assert tag.url == "http://some-updated-url.com"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Tags.update_tag(tag, @invalid_attrs)
      assert tag == Tags.get_tag(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Tags.delete_tag(tag)
      refute Tags.get_tag(tag.id)
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Tags.change_tag(tag)
    end
  end
end

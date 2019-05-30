defmodule Vutuv.BiographiesTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.Biographies
  alias Vutuv.Biographies.{Profile, PhoneNumber}

  @valid_attrs %{
    active_slug: "some active_slug",
    avatar: %Plug.Upload{path: "test/fixtures/elixir_logo.png", filename: "elixir_logo.png"},
    birthday_day: 42,
    birthday_month: 42,
    birthday_year: 42,
    first_name: "some first_name",
    gender: "some gender",
    headline: "some headline",
    honorific_prefix: "some honorific_prefix",
    honorific_suffix: "some honorific_suffix",
    last_name: "some last_name",
    locale: "some locale",
    middlename: "some middlename",
    nickname: "some nickname",
    noindex?: true
  }
  @update_attrs %{
    active_slug: "some updated active_slug",
    avatar: %Plug.Upload{path: "test/fixtures/cool_photo.png", filename: "cool_photo.png"},
    birthday_day: 43,
    birthday_month: 43,
    birthday_year: 43,
    first_name: "some updated first_name",
    gender: "some updated gender",
    headline: "some updated headline",
    honorific_prefix: "some updated honorific_prefix",
    honorific_suffix: "some updated honorific_suffix",
    last_name: "some updated last_name",
    locale: "some updated locale",
    middlename: "some updated middlename",
    nickname: "some updated nickname",
    noindex?: false
  }
  @invalid_attrs %{
    active_slug: nil,
    avatar: nil,
    birthday_day: nil,
    birthday_month: nil,
    birthday_year: nil,
    first_name: nil,
    gender: nil,
    headline: nil,
    honorific_prefix: nil,
    honorific_suffix: nil,
    last_name: nil,
    locale: nil,
    middlename: nil,
    nickname: nil,
    noindex?: nil
  }
  @valid_phone_attrs %{type: "some type", value: "+9123450292"}
  @update_phone_attrs %{type: "some updated type", value: "02122229999"}
  @invalid_phone_attrs %{type: nil, value: "abcde"}

  describe "profiles" do
    alias Vutuv.Biographies.Profile

    def profile_fixture(attrs \\ %{}) do
      {:ok, profile} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Biographies.create_profile()

      profile
    end

    test "list_profiles/0 returns all profiles" do
      profile = profile_fixture()
      assert Biographies.list_profiles() == [profile]
    end

    test "get_profile/1 returns the profile with given id" do
      profile = profile_fixture()
      assert Biographies.get_profile(profile.id) == profile
    end

    test "create_profile/1 with valid data creates a profile" do
      assert {:ok, profile} = Biographies.create_profile(@valid_attrs)
      assert profile.active_slug == "some active_slug"

      assert profile.avatar == %{
               file_name: "elixir_logo.png",
               updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
             }

      assert(profile.birthday_day == 42)
      assert profile.birthday_month == 42
      assert profile.birthday_year == 42
      assert profile.first_name == "some first_name"
      assert profile.gender == "some gender"
      assert profile.headline == "some headline"
      assert profile.honorific_prefix == "some honorific_prefix"
      assert profile.honorific_suffix == "some honorific_suffix"
      assert profile.last_name == "some last_name"
      assert profile.locale == "some locale"
      assert profile.middlename == "some middlename"
      assert profile.nickname == "some nickname"
      assert profile.noindex? == true
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Biographies.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{} = profile} = Biographies.update_profile(profile, @update_attrs)
      assert profile.active_slug == "some updated active_slug"

      assert profile.avatar == %{
               file_name: "cool_photo.png",
               updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
             }

      assert profile.birthday_day == 43
      assert profile.birthday_month == 43
      assert profile.birthday_year == 43
      assert profile.first_name == "some updated first_name"
      assert profile.gender == "some updated gender"
      assert profile.headline == "some updated headline"
      assert profile.honorific_prefix == "some updated honorific_prefix"
      assert profile.honorific_suffix == "some updated honorific_suffix"
      assert profile.last_name == "some updated last_name"
      assert profile.locale == "some updated locale"
      assert profile.middlename == "some updated middlename"
      assert profile.nickname == "some updated nickname"
      assert profile.noindex? == false
    end

    test "update_profile/2 with invalid data returns error changeset" do
      profile = profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Biographies.update_profile(profile, @invalid_attrs)
      assert profile == Biographies.get_profile(profile.id)
    end

    test "change_profile/1 returns a profile changeset" do
      profile = profile_fixture()
      assert %Ecto.Changeset{} = Biographies.change_profile(profile)
    end
  end

  describe "read phone number data" do
    setup [:create_profile, :create_phone_number]

    test "phone_number returns the phone_number with given id", %{
      phone_number: phone_number
    } do
      assert Biographies.get_phone_number(phone_number.id) == phone_number
    end

    test "change phone_number/1 returns a phone_number changeset", %{
      phone_number: phone_number
    } do
      assert %Ecto.Changeset{} = Biographies.change_phone_number(phone_number)
    end
  end

  describe "write phone_number data" do
    setup [:create_profile]

    test "create_phone_number/1 with valid data creates a phone_number", %{profile: profile} do
      assert {:ok, %PhoneNumber{} = phone_number} =
               Biographies.create_phone_number(profile, @valid_phone_attrs)

      assert phone_number.value == "+9123450292"
      assert phone_number.type == "some type"
    end

    test "create_phone_number/1 with invalid data returns error changeset", %{profile: profile} do
      assert {:error, %Ecto.Changeset{}} =
               Biographies.create_phone_number(profile, %{"value" => nil})
    end

    test "update phone_number with valid data updates the phone_number", %{profile: profile} do
      phone_number = insert(:phone_number, %{profile: profile})

      assert {:ok, %PhoneNumber{} = phone_number} =
               Biographies.update_phone_number(phone_number, @update_phone_attrs)

      assert phone_number.type == "some updated type"
      assert phone_number.value == "02122229999"
    end

    test "update phone_number with invalid data returns error changeset", %{profile: profile} do
      phone_number = insert(:phone_number, %{profile: profile})

      assert {:error, %Ecto.Changeset{}} =
               Biographies.update_phone_number(phone_number, @invalid_phone_attrs)
    end
  end

  describe "delete phone_number data" do
    setup [:create_profile, :create_phone_number]

    test "delete_phone_number/1 deletes the phone_number", %{phone_number: phone_number} do
      assert {:ok, %PhoneNumber{}} = Biographies.delete_phone_number(phone_number)
      refute Biographies.get_phone_number(phone_number.id)
    end
  end

  describe "profile_tags" do
    alias Vutuv.Generals
    alias Vutuv.Biographies.ProfileTag

    @valid_tag_attrs %{
      "description" => "some description",
      "name" => "Elixir",
      "url" => "https://elixir-lang.org"
    }

    def tag_fixture(attrs \\ %{}) do
      {:ok, tag} =
        attrs
        |> Enum.into(@valid_tag_attrs)
        |> Generals.create_tag()

      tag
    end

    def profile_tags_fixtures(attrs1 \\ %{}, attrs2 \\ %{}) do
      {:ok, profile_tags} = Biographies.add_profile_tags(attrs1, attrs2)
      profile_tags
    end

    test "list_profile_tags/1 returns all profile_tags of a profile" do
      profile = profile_fixture()
      tag = tag_fixture()
      _profile_tags = profile_tags_fixtures(profile, tag)
      complete_profile = Biographies.get_profile_complete(profile.id)
      assert Biographies.list_profile_tags(profile) == complete_profile.tags
    end

    test "get_profile_tag(integer)/1 returns single profile_tag of a profile" do
      profile = profile_fixture()
      tag = tag_fixture()
      profile_tags = profile_tags_fixtures(profile, tag)
      assert Biographies.get_profile_tag(profile.id, tag.id) == profile_tags
    end

    test "add_profile_tags/1 with profile_id and tag_id" do
      profile = profile_fixture()
      tag = tag_fixture()

      assert {:ok, %ProfileTag{} = profile_tag} = Biographies.add_profile_tags(profile.id, tag.id)
    end

    test "add_profile_tags/1 with profile and tag attrs" do
      profile = profile_fixture()
      tag = tag_fixture()

      assert {:ok, %ProfileTag{} = profile_tag} = Biographies.add_profile_tags(profile, tag)
    end

    test "add_profile_tags/1 with not unique tag returns error changeset" do
      profile = profile_fixture()
      tag = tag_fixture()

      Biographies.add_profile_tags(profile, tag)
      assert {:error, %Ecto.Changeset{}} = Biographies.add_profile_tags(profile, tag)
    end

    test "remove_profile_tags/2 deletes the tag with profile_id and tag id " do
      profile = profile_fixture()
      tag = tag_fixture()
      _profile_tags = profile_tags_fixtures(profile, tag)

      assert {:ok, %ProfileTag{}} = Biographies.remove_profile_tags(profile.id, tag.id)
      refute Biographies.get_profile_tag(profile.id, tag.id)
    end

    test "remove_profile_tags/2 deletes the tag with profile_tags attrs " do
      profile = profile_fixture()
      tag = tag_fixture()
      profile_tags = profile_tags_fixtures(profile, tag)

      assert {:ok, %ProfileTag{}} = Biographies.remove_profile_tags(profile_tags)
      refute Biographies.get_profile_tag(profile_tags.profile_id, profile_tags.tag_id)
    end
  end

  defp create_profile(_) do
    {:ok, profile} = Biographies.create_profile(@valid_attrs)
    {:ok, %{profile: profile}}
  end

  defp create_phone_number(%{profile: profile}) do
    {:ok, phone_number} = Biographies.create_phone_number(profile, @valid_phone_attrs)
    {:ok, %{phone_number: phone_number}}
  end
end

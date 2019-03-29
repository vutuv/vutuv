defmodule Vutuv.BiographiesTest do
  use Vutuv.DataCase

  alias Vutuv.Biographies

  describe "profiles" do
    alias Vutuv.Biographies.Profile

    @valid_attrs %{
      active_slug: "some active_slug",
      avatar: "some avatar",
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
      avatar: "some updated avatar",
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
      assert {:ok, %Profile{} = profile} = Biographies.create_profile(@valid_attrs)
      assert profile.active_slug == "some active_slug"
      assert profile.avatar == "some avatar"
      assert profile.birthday_day == 42
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
      assert profile.avatar == "some updated avatar"
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

    test "delete_profile/1 deletes the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{}} = Biographies.delete_profile(profile)
      refute Biographies.get_profile(profile.id)
    end

    test "change_profile/1 returns a profile changeset" do
      profile = profile_fixture()
      assert %Ecto.Changeset{} = Biographies.change_profile(profile)
    end
  end
end

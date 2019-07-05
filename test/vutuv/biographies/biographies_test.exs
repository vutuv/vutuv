defmodule Vutuv.BiographiesTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.{Biographies, Generals}
  alias Vutuv.Biographies.{Profile, ProfileTag, PhoneNumber}

  @valid_attrs %{
    avatar: %Plug.Upload{path: "test/fixtures/elixir_logo.png", filename: "elixir_logo.png"},
    full_name: "#{Faker.Name.first_name()} #{Faker.Name.last_name()}",
    gender: Enum.random(["female", "male", "other"]),
    locale: "en_US",
    preferred_name: Faker.Name.first_name(),
    birthday: ~D[1980-01-15],
    headline: Faker.Company.bs(),
    honorific_prefix: "Dr",
    honorific_suffix: "PhD"
  }
  @update_attrs %{
    headline: Faker.Company.bs(),
    preferred_name: Faker.Name.first_name()
  }
  @invalid_attrs %{
    preferred_name: String.duplicate("GardenGnome", 8)
  }
  @valid_phone_attrs %{type: "mobile", value: "+9123450292"}
  @update_phone_attrs %{type: "work", value: "02122229999"}
  @invalid_phone_attrs %{type: nil, value: "abcde"}

  describe "profiles" do
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

      assert profile.avatar == %{
               file_name: "elixir_logo.png",
               updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
             }

      assert profile.full_name
      assert profile.gender in ["female", "male", "other"]
      assert profile.preferred_name
      assert profile.honorific_prefix == "Dr"
      assert profile.honorific_suffix == "PhD"
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Biographies.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()

      assert {:ok, %Profile{headline: headline, preferred_name: preferred_name}} =
               Biographies.update_profile(profile, @update_attrs)

      assert headline != profile.headline
      assert preferred_name != profile.preferred_name
    end

    test "can update locale with valid data" do
      profile = profile_fixture()
      assert profile.locale == "en_US"

      assert {:ok, %Profile{locale: locale}} =
               Biographies.update_profile(profile, %{"locale" => "de_CH"})

      assert locale == "de_CH"
    end

    test "returns error when updating locale with invalid data" do
      profile = profile_fixture()
      assert profile.locale == "en_US"

      assert {:error, %Ecto.Changeset{} = changeset} =
               Biographies.update_profile(profile, %{"locale" => "zh_CN"})

      assert %{locale: ["Unsupported locale"]} = errors_on(changeset)
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
      assert phone_number.type == "mobile"
    end

    test "create_phone_number/1 with invalid data returns error changeset", %{profile: profile} do
      assert {:error, %Ecto.Changeset{}} =
               Biographies.create_phone_number(profile, %{"value" => nil})
    end

    test "update phone_number with valid data updates the phone_number", %{profile: profile} do
      phone_number = insert(:phone_number, %{profile: profile})

      assert {:ok, %PhoneNumber{} = phone_number} =
               Biographies.update_phone_number(phone_number, @update_phone_attrs)

      assert phone_number.type == "work"
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
    @valid_tag_attrs %{
      "description" =>
        "Elixir is a functional, concurrent, general-purpose programming language that runs on the Erlang virtual machine (BEAM).",
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

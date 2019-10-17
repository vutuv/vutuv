defmodule Vutuv.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Vutuv.Repo

  alias Vutuv.{UserConnections, UserProfiles, UserProfiles.User}

  def user_factory do
    full_name = "#{Faker.Name.first_name()} #{Faker.Name.last_name()}"

    %User{
      email_addresses: build_list(1, :email_address),
      user_credential: build(:user_credential),
      slug: Slugger.slugify_downcase(full_name, ?.),
      full_name: full_name,
      preferred_name: Faker.Name.first_name(),
      gender: sequence(:gender, ["female", "male"]),
      birthday: Faker.Date.date_of_birth(18..59),
      headline: Faker.Company.bs(),
      honorific_prefix: sequence(:honorific_prefix, ["Dr", "Mr", "Ms"]),
      honorific_suffix: sequence(:honorific_suffix, ["", "PhD"]),
      locale: sequence(:locale, ["en", "de"]),
      noindex: false
    }
  end

  def user_credential_factory do
    %Vutuv.Accounts.UserCredential{
      password_hash: Argon2.hash_pwd_salt("hard2gue$$"),
      confirmed: true
    }
  end

  def address_factory do
    %Vutuv.UserProfiles.Address{
      user: build(:user),
      description: Faker.Company.bs(),
      line_1: Faker.Address.building_number(),
      line_2: Faker.Address.street_name(),
      city: Faker.Address.city(),
      state: Faker.Address.state(),
      country: Faker.Address.country(),
      zip_code: Faker.Address.postcode()
    }
  end

  def email_address_factory do
    %Vutuv.Devices.EmailAddress{
      value: sequence(:value, &"email-#{&1}@example.com"),
      is_public: true,
      description: Faker.Company.bs(),
      position: 1,
      verified: false
    }
  end

  def post_factory do
    %Vutuv.Publications.Post{
      user: build(:user),
      title: Faker.Company.name(),
      body: Faker.Lorem.Shakespeare.romeo_and_juliet(),
      published_at: DateTime.truncate(DateTime.utc_now(), :second)
    }
  end

  def phone_number_factory do
    %Vutuv.Devices.PhoneNumber{
      value: Faker.Phone.EnUs.phone(),
      type: sequence(:type, ["work", "home", "mobile"])
    }
  end

  def social_media_account_factory do
    %Vutuv.SocialNetworks.SocialMediaAccount{
      user: build(:user),
      provider: "Facebook",
      value: Faker.Name.title()
    }
  end

  def tag_factory do
    tag_name = Enum.random(["JavaScript", "Prolog", "Painting"])

    %Vutuv.Tags.Tag{
      description: "#{tag_name} expertise",
      name: "#{tag_name}",
      url: "http://some-url.com"
    }
  end

  def post_tag_factory do
    %Vutuv.Tags.PostTag{
      post: build(:post),
      tag: build(:tag)
    }
  end

  def user_tag_factory do
    %Vutuv.Tags.UserTag{
      tag: build(:tag),
      user: build(:user)
    }
  end

  def work_experience_factory do
    %Vutuv.Biographies.WorkExperience{
      user: build(:user),
      description: Faker.Company.bs(),
      title: Faker.Name.title(),
      organization: Faker.Company.name(),
      start_date: Faker.Date.between(~D[2010-12-01], ~D[2015-12-01]),
      end_date: Faker.Date.between(~D[2016-12-01], ~D[2019-12-01])
    }
  end

  def add_user_assocs(%User{} = user) do
    user_tag = insert(:user_tag, %{user: user})
    other_users = insert_list(6, :user)
    followee_ids = Enum.map(other_users, & &1.id)

    Enum.each(
      followee_ids,
      &UserConnections.create_user_connection(%{"followee_id" => &1, "follower_id" => user.id})
    )

    Enum.each(
      Enum.take(followee_ids, 4),
      &UserConnections.create_user_connection(%{"followee_id" => user.id, "follower_id" => &1})
    )

    for other <- other_users do
      Vutuv.Tags.create_user_tag_endorsement(other, %{"user_tag_id" => user_tag.id})
    end

    %{"id" => user.id}
    |> UserProfiles.get_user!()
    |> UserProfiles.get_user_overview()
  end

  def escape_html(input) do
    String.replace(input, "'", "&#39;")
  end
end

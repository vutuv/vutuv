defmodule Vutuv.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Vutuv.Repo

  def user_factory do
    full_name = "#{Faker.Name.first_name()} #{Faker.Name.last_name()}"

    %Vutuv.UserProfiles.User{
      email_addresses: build_list(1, :email_address),
      user_credential: build(:user_credential),
      slug: Slugger.slugify_downcase(full_name, ?.),
      full_name: full_name,
      preferred_name: Faker.Name.first_name(),
      gender: sequence(:gender, ["female", "male"]),
      birthday: Faker.Date.date_of_birth(18..59),
      # FIXME: riverrun - 2019-04-08
      # add valid avatar entry
      # avatar: "",
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

  def tag_factory do
    %Vutuv.Tags.Tag{}
  end
end

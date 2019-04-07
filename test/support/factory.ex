defmodule Vutuv.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Vutuv.Repo

  def user_factory do
    %Vutuv.Accounts.User{
      password_hash: Argon2.hash_pwd_salt("hard2gue$$"),
      confirmed_at: DateTime.truncate(DateTime.utc_now(), :second)
    }
  end

  def email_address_factory do
    %Vutuv.Accounts.EmailAddress{
      user: build(:user),
      value: sequence(:value, &"email-#{&1}@example.com"),
      is_public: true,
      description: Faker.Company.bs(),
      position: 1,
      verified: true
    }
  end

  def profile_factory do
    %Date{year: year, month: month, day: day} = Faker.Date.date_of_birth(18..59)

    %Vutuv.Biographies.Profile{
      user: build(:user),
      first_name: Faker.Name.first_name(),
      last_name: Faker.Name.last_name(),
      middlename: Faker.Name.first_name(),
      nickname: Faker.Name.first_name(),
      gender: sequence(:gender, ["female", "male"]),
      birthday_day: day,
      birthday_month: month,
      birthday_year: year,
      active_slug: "",
      avatar: "",
      headline: "",
      honorific_prefix: "",
      honorific_suffix: "",
      locale: "",
      noindex?: true
    }
  end

  def post_factory do
    %Vutuv.Socials.Post{
      user: build(:user),
      body: Faker.Company.bs(),
      page_info_cache: "",
      title: Faker.Company.name(),
      visibility_level: "private"
    }
  end
end

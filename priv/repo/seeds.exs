# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use `mix ecto.setup` or `mix ecto.reset`
#

js_tag_attrs = %{
  "description" => "JavaScript expertise",
  "name" => "JavaScript",
  "url" => "http://some-url.com"
}

prolog_tag_attrs = %{
  "description" => "Logic programming will save the world",
  "name" => "Prolog",
  "url" => "http://some-other-url.com"
}

users_attrs = [
  %{
    "email" => "jane.doe@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Jane Doe",
    "gender" => "female"
  },
  %{
    "email" => "hans.will@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Hans Will",
    "gender" => "male",
    "noindex" => true
  },
  %{
    "email" => "shanie.beatty@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Shanie Beatty",
    "gender" => "female"
  }
]

for user <- users_attrs do
  {:ok, %{email_addresses: [email_address], user_credential: user_credential} = user} =
    Vutuv.UserProfiles.create_user(user)

  Vutuv.Accounts.confirm_user(user_credential)
  Vutuv.Devices.verify_email_address(email_address)
  name = String.replace(user.full_name, " ", ".")

  Vutuv.Devices.create_email_address(user, %{
    "value" => "#{name}_123@example.com"
  })

  Vutuv.Tags.create_user_tag(user, js_tag_attrs)
  Vutuv.Tags.create_user_tag(user, prolog_tag_attrs)

  {:ok, post} =
    Vutuv.Publications.create_post(user, %{
      body: String.duplicate("Blablabla ", 25),
      title: "Something to do with #{user.full_name}",
      visibility_level: "public"
    })

  Vutuv.Tags.create_post_tag(post, js_tag_attrs)
end

user_cred = Vutuv.Accounts.get_user_credential(%{"email" => "jane.doe@example.com"})
Vutuv.Accounts.set_admin(user_cred, %{is_admin: true})

user_tags = Vutuv.Repo.all(Vutuv.Tags.UserTag)
created_users = Vutuv.UserProfiles.list_users()

for user <- created_users do
  other_user_ids =
    Enum.flat_map(created_users, fn u ->
      if u.id == user.id, do: [], else: [u.id]
    end)

  Enum.each(
    other_user_ids,
    &Vutuv.UserConnections.create_user_connection(%{"followee_id" => user.id, "follower_id" => &1})
  )
end

other_users_attrs = [
  %{
    "email" => "german.keeling@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "German Keeling",
    "gender" => "male",
    "locale" => "de"
  },
  %{
    "email" => "vivian.nikolaus@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Vivian Nikolaus",
    "gender" => "female",
    "noindex" => true
  },
  %{
    "email" => "kelly.abernathy@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Kelly Abernathy",
    "gender" => "female"
  },
  %{
    "email" => "nat.carter@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Nat Carter",
    "gender" => "male"
  },
  %{
    "email" => "baby.deckow@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Baby Deckow",
    "gender" => "male",
    "noindex" => true,
    "locale" => "de_DE"
  },
  %{
    "email" => "ewell.reinger@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Ewell Reinger",
    "gender" => "female"
  },
  %{
    "email" => "devonte.okuneva@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Devonte Okuneva",
    "gender" => "male",
    "locale" => "de"
  },
  %{
    "email" => "deron.gleason@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Deron Gleason",
    "gender" => "female"
  },
  %{
    "email" => "mckenzie.lesch@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Mckenzie Lesch",
    "gender" => "male",
    "noindex" => true
  },
  %{
    "email" => "gregory.collins@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Gregory Collins",
    "gender" => "male"
  },
  %{
    "email" => "consuelo.torp@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Consuelo Torp",
    "gender" => "male"
  },
  %{
    "email" => "xzavier.towne@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Xzavier Towne",
    "gender" => "male"
  },
  %{
    "email" => "dorothea.west@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Dorothea West",
    "gender" => "female"
  },
  %{
    "email" => "anthony.tillman@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Anthony Tillman",
    "gender" => "male",
    "noindex" => true,
    "locale" => "de_CH"
  },
  %{
    "email" => "hollie.rippin@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Hollie Rippin",
    "gender" => "female"
  },
  %{
    "email" => "jennyfer.fritsch@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Jennyfer Fritsch",
    "gender" => "female"
  },
  %{
    "email" => "amira.anderson@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Amira Anderson",
    "gender" => "female"
  },
  %{
    "email" => "jordan.fadel@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Jordan Fadel",
    "gender" => "male",
    "noindex" => true
  },
  %{
    "email" => "garrick.crona@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Garrick Crona",
    "gender" => "male"
  },
  %{
    "email" => "joan.reilly@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Joan Reilly",
    "gender" => "female"
  },
  %{
    "email" => "magnus.thompson@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Magnus Thompson",
    "gender" => "male",
    "locale" => "de"
  }
]

followee_ids = Enum.map(users_attrs, &Vutuv.UserProfiles.get_user!(&1).id)

for user <- other_users_attrs do
  {:ok, %{email_addresses: [email_address], user_credential: user_credential} = user} =
    Vutuv.UserProfiles.create_user(user)

  Vutuv.Accounts.confirm_user(user_credential)
  Vutuv.Devices.verify_email_address(email_address)

  Enum.each(
    followee_ids,
    &Vutuv.UserConnections.create_user_connection(%{"followee_id" => &1, "follower_id" => user.id})
  )

  for user_tag <- user_tags do
    Vutuv.Tags.create_user_tag_endorsement(user, %{"user_tag_id" => user_tag.id})
  end
end

unverified_user_attrs = [
  %{
    "email" => "garnett.zulauf@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Garnett Zulauf",
    "gender" => "male"
  },
  %{
    "email" => "karina.mcclure@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "Karina McClure",
    "gender" => "female"
  },
  %{
    "email" => "john.smith@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "John Smith",
    "gender" => "male"
  }
]

for user <- unverified_user_attrs do
  {:ok, _user} = Vutuv.UserProfiles.create_user(user)
end

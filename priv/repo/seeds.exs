# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use `mix ecto.setup` or `mix ecto.reset`
#

{:ok, js_tag} =
  Vutuv.Tags.create_tag(%{
    "description" => "JavaScript expertise",
    "name" => "JavaScript",
    "url" => "http://some-url.com"
  })

{:ok, prolog_tag} =
  Vutuv.Tags.create_tag(%{
    "description" => "Logic programming will save the world",
    "name" => "Prolog",
    "url" => "http://some-other-url.com"
  })

users = [
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

for user <- users do
  {:ok, %{email_addresses: [email_address], user_credential: user_credential} = user} =
    Vutuv.Accounts.create_user(user)

  Vutuv.Accounts.confirm_user(user_credential)
  Vutuv.Accounts.confirm_email_address(email_address)
  name = String.replace(user.full_name, " ", ".")

  Vutuv.Accounts.create_email_address(user, %{
    "value" => "#{name}_123@example.com"
  })

  Vutuv.Accounts.add_user_tags(user, [js_tag.id, prolog_tag.id])

  {:ok, post} =
    Vutuv.Socials.create_post(user, %{
      body: String.duplicate("Blablabla ", 25),
      title: "Something to do with #{user.full_name}",
      visibility_level: "public"
    })

  Vutuv.Socials.add_post_tags(post, [js_tag.id])
end

created_users = Vutuv.Accounts.list_users()

for user <- created_users do
  other_user_ids =
    Enum.flat_map(created_users, fn u ->
      if u.id == user.id, do: [], else: [u.id]
    end)

  Vutuv.Accounts.add_leaders(user, other_user_ids)
end

other_users = [
  %{
    "email" => "german.keeling@example.com",
    "password" => "reallyHard2gue$$",
    "full_name" => "German Keeling",
    "gender" => "male"
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
    "noindex" => true
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
    "gender" => "male"
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
    "noindex" => true
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
    "gender" => "male"
  },
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

for user <- other_users do
  {:ok, %{email_addresses: [email_address], user_credential: user_credential} = user} =
    Vutuv.Accounts.create_user(user)

  Vutuv.Accounts.confirm_user(user_credential)
  Vutuv.Accounts.confirm_email_address(email_address)
  leader_ids = Enum.map(users, &Vutuv.Accounts.get_user(&1).id)
  Vutuv.Accounts.add_leaders(user, leader_ids)
end

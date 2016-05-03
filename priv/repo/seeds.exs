# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Vutuv.Repo.insert!(%Vutuv.SomeModel{})

sw = Vutuv.Repo.insert! (%Vutuv.User{first_name: "Stefan", last_name: "Wintermeyer", gender: "male"})
Vutuv.Repo.insert! (%Vutuv.Email{value: "stefan.wintermeyer@amooma.de", user_id: sw.id})
Vutuv.Repo.insert! (%Vutuv.Email{value: "sw@amooma.de", user_id: sw.id})

Vutuv.Repo.insert! (%Vutuv.User{first_name: "Oliver", last_name: "Andrich", gender: "male"})
Vutuv.Repo.insert! (%Vutuv.User{first_name: "Lennex", last_name: "Zinyando", gender: "male"})
Vutuv.Repo.insert! (%Vutuv.User{first_name: "Kasper", last_name: "Tidemann", gender: "male"})

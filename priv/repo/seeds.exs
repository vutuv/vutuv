# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Vutuv.Repo.insert!(%Vutuv.SomeModel{})

Vutuv.Repo.insert! (%Vutuv.User{first_name: "Stefan", last_name: "Wintermeyer"})
Vutuv.Repo.insert! (%Vutuv.User{first_name: "Oliver", last_name: "Andrich"})
Vutuv.Repo.insert! (%Vutuv.User{first_name: "Lennex", last_name: "Zinyando"})
Vutuv.Repo.insert! (%Vutuv.User{first_name: "Kasper", last_name: "Tidemann"})

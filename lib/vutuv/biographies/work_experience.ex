defmodule Vutuv.Biographies.WorkExperience do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.UserProfiles.User

  @type t :: %__MODULE__{
          id: integer,
          description: String.t(),
          end_date: Date.t(),
          organization: String.t(),
          slug: String.t(),
          start_date: Date.t(),
          title: String.t(),
          user_id: integer,
          user: User.t() | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "work_experiences" do
    field :description, :string
    field :end_date, :date
    field :organization, :string
    field :slug, :string
    field :start_date, :date
    field :title, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(work_experience, attrs) do
    work_experience
    |> cast(attrs, [:organization, :title, :description, :start_date, :end_date, :slug])
    |> validate_required([:organization, :title])
  end
end

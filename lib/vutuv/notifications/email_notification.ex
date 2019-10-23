defmodule Vutuv.Notifications.EmailNotification do
  use Ecto.Schema

  import Ecto.Changeset

  alias Vutuv.UserProfiles.User

  @type t :: %__MODULE__{
          id: integer,
          body: String.t(),
          delivered: boolean,
          subject: String.t(),
          owner_id: integer,
          owner: User.t() | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "email_notifications" do
    field :body, :string
    field :delivered, :boolean, default: false
    field :subject, :string

    belongs_to :owner, User

    timestamps()
  end

  @doc false
  def changeset(email_notification, attrs) do
    email_notification
    |> cast(attrs, [:subject, :body, :delivered])
    |> validate_required([:subject, :body, :delivered])
  end
end

defmodule Vutuv.Tags.UserTag do
  use Ecto.Schema

  alias Vutuv.Tags.{Tag, UserTagEndorsement}
  alias Vutuv.UserProfiles.User

  @type t :: %__MODULE__{
          id: integer,
          tag: Tag.t() | %Ecto.Association.NotLoaded{},
          user: User.t() | %Ecto.Association.NotLoaded{}
        }

  schema "user_tags" do
    belongs_to :tag, Tag
    belongs_to :user, User

    has_many :user_tag_endorsements, UserTagEndorsement, on_delete: :delete_all
  end
end

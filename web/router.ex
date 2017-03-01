defmodule Vutuv.Router do
  use Vutuv.Web, :router
  alias Vutuv.Plug, as: Plug

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    #plug Vutuv.Plug.ManageCookies
    plug :put_secure_browser_headers
    plug Plug.ConfigureSession, repo: Vutuv.Repo
    plug Plug.Locale
  end

  pipeline :user_pipe do
    plug Plug.UserResolveSlug
    plug Plug.EnsureValidated
  end

  pipeline :api do
    plug :accepts, ["json-api"]
    plug Plug.PutAPIHeaders
    plug Plug.Locale
  end

  pipeline :render_404 do
    plug Plug.All404
  end

  scope "/", Vutuv do
    pipe_through :browser # Use the default browser stack


    resources "/tags", TagController, only: [:index, :show], param: "slug"

    get "/", PageController, :index
    get "/impressum", PageController, :impressum
    get "/listings/most_followed_users", PageController, :most_followed_users
    get "/new_registration", PageController, :redirect_index
    post "/new_registration", PageController, :new_registration

    # TODO: delete the following route entries
    resources "/memberships", MembershipController, only: [:create, :delete]
    resources "/connections", ConnectionController, only: [:create, :delete] do
      resources "/memberships", MembershipController, only: [:create, :delete]
    end

    resources "/search_queries", SearchQueryController, only: [:create, :new, :show]

    resources "/users", UserController, param: "slug" do
      pipe_through :user_pipe
      resources "/emails", EmailController
      resources "/slugs", SlugController, only: [:index, :new, :create, :show, :update]
      resources "/groups", GroupController
      resources "/followers", FollowerController, only: [:index]
      resources "/followees", FolloweeController, only: [:index]
      resources "/user_tag_endorsements", UserTagEndorsementController, only: [:create, :delete], as: :tag_endorsement
      resources "/phone_numbers", PhoneNumberController
      resources "/dates", DateController
      resources "/links", UrlController
      resources "/social_media_accounts", SocialMediaAccountController
      resources "/work_experiences", WorkExperienceController
      resources "/addresses", AddressController
      resources "/oauth_providers", OAuthProviderController
      resources "/search_terms", SearchTermController, only: [:show,:index]
      resources "/tags", UserTagController, only: [:new, :create, :show, :delete, :index], as: :tag
      resources "/job_postings", JobPostingController, param: "job_slug" do
        resources "/tags", JobPostingTagController, as: :tag, only: [:index, :new, :create, :delete]
      end
      resources "/recruiter_subscriptions", RecruiterSubscriptionController, only: [:index, :new, :create]
    end

    post "/users/:slug/tags_create", UserController, :tags_create

    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/magic/login/:magiclink", SessionController, :show
    get "/magic/delete/:magiclink", UserController, :magic_delete
    get "/magic/email/:magiclink", EmailController, :magic_create
    get "/follow_back/:id", UserController, :follow_back
  end

  scope "/admin", Vutuv.Admin, as: :admin do
    pipe_through :browser
    resources "/", AdminController, only: [:index]
    post "/slugs", SlugController, :update
    post "/users", UserController, :update
    resources "/locales", LocaleController, only: [:index, :show]
    resources "/exonyms", ExonymController
    resources "/tags", TagController, param: "slug" do
      resources "/tag_localizations", TagLocalizationController, as: :localization do
        resources "/tag_urls", TagUrlController, as: :url
      end
      resources "/tag_synonyms", TagSynonymController, as: :synonym
      resources "/tag_closures", TagClosureController, as: :closure
    end
    resources "/recruiter_packages", RecruiterPackageController, param: "package_slug"
  end

  scope "/api/1.0/", as: :api do
    pipe_through :api

    resources "/users", Vutuv.Api.UserController, param: "slug" do

      pipe_through :user_pipe
      get "/vcard", Vutuv.Api.VCardController, :get

      resources "/emails", Vutuv.Api.EmailController, only: [:index, :show]
      pipe_through :render_404
      resources "/slugs", Vutuv.Api.SlugController, only: [:index, :show]

      resources "/groups", Vutuv.Api.GroupController, only: [:index, :show]
      resources "/followers", Vutuv.Api.FollowerController, only: [:index]
      resources "/followees", Vutuv.Api.FolloweeController, only: [:index]

      resources "/phone_numbers", Vutuv.Api.PhoneNumberController, only: [:index, :show]
      resources "/links", Vutuv.Api.UrlController, only: [:index, :show]
      resources "/social_media_accounts", Vutuv.Api.SocialMediaAccountController, only: [:index, :show]
      resources "/work_experiences", Vutuv.Api.WorkExperienceController, only: [:index, :show]
      resources "/addresses", Vutuv.Api.AddressController, only: [:index, :show]
      resources "/search_terms", Vutuv.Api.SearchTermController, only: [:index, :show]

    end

    pipe_through :render_404

  end

  scope "/", as: :default do
    pipe_through :browser
    get "/:slug", Vutuv.PageController, :redirect_user
  end
end

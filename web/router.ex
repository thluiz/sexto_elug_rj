defmodule SextoElugRj.Router do
  use SextoElugRj.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SextoElugRj do
    pipe_through :browser # Use the default browser stack

    get "/game", GamePageController, :index
    get "/", GamePageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", SextoElugRj do
  #   pipe_through :api
  # end
end
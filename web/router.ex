defmodule ElmExWhiteboard.Router do
  use ElmExWhiteboard.Web, :router

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

  scope "/", ElmExWhiteboard do
    pipe_through :browser

    get "/:channel", PageController, :room
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElmExWhiteboard do
  #   pipe_through :api
  # end
end

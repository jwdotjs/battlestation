defmodule Battlestation.Router do
  use Battlestation.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Battlestation do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    post "/", PageController, :create
    put "/", PageController, :update
  end

end

defmodule SextoElugRj.GamePageController do
  use SextoElugRj.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

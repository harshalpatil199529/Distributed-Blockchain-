defmodule BitcoinmineWeb.PageController do
  use BitcoinmineWeb, :controller

  def index(conn, _params) do
    spawn fn -> Start.main end
    render conn, "index.html"
  end
end

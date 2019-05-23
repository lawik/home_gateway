defmodule HomeGatewayWeb.PageController do
  use HomeGatewayWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

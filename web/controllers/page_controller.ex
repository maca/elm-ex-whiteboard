defmodule ElmExWhiteboard.PageController do
  use ElmExWhiteboard.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def room(conn, %{"channel" => channel}) do
    render conn, "room.html", channel: channel,
           client_id: client_id
  end

  defp client_id do
    length = 10

    :crypto.strong_rand_bytes(length)
      |> Base.url_encode64
      |>  binary_part(0, length)
  end
end

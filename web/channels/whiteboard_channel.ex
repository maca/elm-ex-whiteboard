defmodule ElmExWhiteboard.WhiteboardChannel do
  use Phoenix.Channel
  require Logger
  import Ecto.Query, only: [from: 2]

  alias ElmExWhiteboard.Point
  alias ElmExWhiteboard.Repo


  def join("whiteboard:" <> session_id, _payload, socket) do
    send(self, :after_join)
    {:ok, assign(socket, :session_id, session_id)}
  end


  def handle_in(event = "new-point", msg, socket) do
    %{client_id: client, session_id: session} = socket.assigns

    if client == msg["client_id"] do
      Task.async fn -> insert_point(session, msg) end
      broadcast_from socket, event, msg
    end

    {:reply, {:ok, msg}, socket}
  end

  def handle_in(_event, msg, socket) do
    {:reply, {:ok, msg}, socket}
  end


  def handle_info(:after_join, socket) do
    push_lines(socket, socket.assigns.session_id)
    {:noreply, socket}
  end

  def handle_info(_event, socket), do: {:noreply, socket}


  defp push_lines(socket, session_id) do
    query = from pt in Point,
      where: pt.session_id == ^session_id,
      order_by: [pt.line_id, pt.id],
      select: map(pt, ^Point.public_fields)

    points = Repo.all(query)

    push socket, "set-state", %{"points" => points}
  end


  defp insert_point(session_id, data) do
    Map.put(data, "session_id", session_id) |> insert_point
  end

  defp insert_point(data) do
    changeset     = Point.changeset(%Point{}, data)
    {:ok, _point} = Repo.insert(changeset)
  end
end

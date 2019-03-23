defmodule BitcoinmineWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end
  def join(_room, _params, _socket) do
    {:error, %{reason: "you can only join the lobby"}}
  end

  def handle_in("new_message", body, socket) do
    # broadcast! socket, "new_message", body
    push(socket,"new_message",body)
    {:noreply, socket}
  end
  def handle_in("new_balance", body, socket) do
    # broadcast! socket, "new_message", body
    push(socket,"new_balance",body)
    {:noreply, socket}
  end
  def handle_in("new_chart", body, socket) do
    # broadcast! socket, "new_message", body
    push(socket,"new_chart",body)
    {:noreply, socket}
  end
  def handle_in("new_chart1", body, socket) do
    # broadcast! socket, "new_message", body
    push(socket,"new_chart1",body)
    {:noreply, socket}
  end


end



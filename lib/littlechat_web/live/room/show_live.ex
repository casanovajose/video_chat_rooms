defmodule LittlechatWeb.Room.ShowLive do
  @moduledoc """
  Liveview for creating and joining rooms
  """
  use LittlechatWeb, :live_view
  alias Littlechat.Organizer

  @impl true
  def render(assigns) do
    ~L"""
    <h1><%= @room.title %></h1>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    case Organizer.get_room(slug) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "No existe la sala")
         |> push_redirect(to: Routes.room_new_path(socket, :new))
        }
      room ->
        {:ok,
         socket
         |> assign(:room, room)
        }
    end
  end
end

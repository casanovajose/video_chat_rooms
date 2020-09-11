defmodule LittlechatWeb.Room.ShowLive do
  @moduledoc """
  Liveview for creating and joining rooms
  """
  use LittlechatWeb, :live_view
  alias Littlechat.Organizer
  alias Littlechat.ConnectedUser

  alias LittlechatWeb.Presence
  alias Phoenix.Socket.Broadcast

  @impl true
  def render(assigns) do
    ~L"""
    <h1><%= @room.title %></h1>
    <h2>Connected users</h2>
    <%= #@connected_users %>
    <ul>
    <%= for uuid <- @connected_users do %>
      <li><%= uuid %></li>
    <% end %>
    </ul>

    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    IO.inspect("room:" <> slug)
    user = create_connected_user()
    Phoenix.PubSub.subscribe(Littlechat.PubSub, "room:" <> slug)
    {:ok, _} = Presence.track(self(), "room:" <> slug, user.uuid, %{})

    case Organizer.get_room(slug) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "No existe la sala")
         |> push_redirect(to: Routes.new_path(socket, :new))
        }
      room ->
        {:ok,
         socket
         |> assign(:room, room)
         |> assign(:user, user)
         |> assign(:slug, slug)
         |> assign(:connected_users, [])
        }
    end
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    #IO.inspect(socket.assigns)
    {:noreply,
     socket
     |> assign(:connected_users, list_present(socket))
    }
  end

  defp list_present(socket) do
    IO.inspect(Presence.list("room:" <> socket.assigns.room.slug))
    Presence.list("room:" <> socket.assigns.room.slug)
    |> Enum.map(fn {k, _} -> k end) # we don't need the metadata now
  end

  defp create_connected_user do
    %ConnectedUser{uuid: UUID.uuid4()}
  end
end

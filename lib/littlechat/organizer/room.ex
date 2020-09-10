defmodule Littlechat.Organizer.Room do
  @moduledoc """
  Schema for creating video chat rooms
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :slug, :string
    field :title, :string

    timestamps()
  end

  @fields [:title, :slug]
  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:title, :slug])
    |> validate_required([:title, :slug])
    |> format_slug()
    |> unique_constraint(:slug)

  end

  defp format_slug(%Ecto.Changeset{changes: %{slug: _}} = changeset) do
    IO.inspect(changeset)
    changeset
    |> update_change(:slug, fn slug ->
      slug
      |> String.downcase()
      |> String.replace(" ", "-")
    end)
  end
  defp format_slug(changeset), do: changeset
end

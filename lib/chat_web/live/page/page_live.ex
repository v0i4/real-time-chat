defmodule ChatWeb.PageLive do
  use ChatWeb, :live_view

  @impl true
  def mount(_p, _s, socket) do
    {:ok, assign(socket, page_title: "_anonychat_", room_id: "")}
  end

  @impl true
  def handle_event("random-room", _p, socket) do
    random_slug = "/" <> MnemonicSlugs.generate_slug(3)

    {:noreply, push_redirect(socket, to: random_slug)}
  end

  @impl true
  def handle_event("custom-room", %{"room_id" => room_id}, socket) do
    custom_room = "/" <> room_id

   {:noreply, push_redirect(socket, to: custom_room)}
  end
end

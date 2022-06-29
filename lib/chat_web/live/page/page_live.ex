defmodule ChatWeb.PageLive do
  use ChatWeb, :live_view

  @impl true
  def mount(_p, _s, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("random-room", _p, socket) do
    random_slug = "/" <> MnemonicSlugs.generate_slug(3)

    {:noreply, push_redirect(socket, to: random_slug)}
  end
end

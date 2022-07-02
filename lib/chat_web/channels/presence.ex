defmodule ChatWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :chat,
    pubsub_server: Chat.PubSub

  def update_presence(pid, topic, key, payload) do
    metas =
      ChatWeb.Presence.get_by_key(topic, key)[:metas]
      |> List.first()
      |> Map.merge(payload)

#    IO.inspect pid
#    IO.inspect topic
#    IO.inspect key
#    IO.inspect metas
    ChatWeb.Presence.update(pid, topic, key, metas)
  end
end

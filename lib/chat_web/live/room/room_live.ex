defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view

  @impl true
  def mount(%{"id" => room_id}, _s, socket) do
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(2)
    is_typing = false

    if connected?(socket) do
      ChatWeb.Endpoint.subscribe(topic)

      ChatWeb.Presence.track(self(), topic, username, %{
        typing: is_typing,
        username: username
      })
    end

    {:ok,
     assign(socket,
       room_id: room_id,
       topic: topic,
       message: "",
       messages: [],
       temporary_assigns: [messages: []],
       username: username,
       user_list: []
     )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{uuid: UUID.uuid4(), content: message, username: socket.assigns.username}
    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_event("is-typing", params, socket = %{assigns: %{topic: topic, username: username}}) do
    if params["chat"]["message"] == "" do
      ChatWeb.Presence.update_presence(self(), topic, username, %{typing: false})
    else
      ChatWeb.Presence.update_presence(self(), topic, username, %{typing: true})
      # bolar um timeout aqui, p aperfeicoar a funcao
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "stop_typing",
        value,
        socket = %{assigns: %{topic: topic, username: username, message: message}}
      ) do
    # message = Chats.change_message(message, %{content: value})
    ChatWeb.Presence.update_presence(self(), topic, username, %{typing: false})
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, assign(socket, messages: [message])}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves} = payload},
        socket
      ) do
    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system, uuid: UUID.uuid4(), content: "#{username} joined"}
      end)

    leave_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system, uuid: UUID.uuid4(), content: "#{username} left"}
      end)

    user_list =
      ChatWeb.Presence.list(socket.assigns.topic)
      |> Enum.map(fn {_username, data} ->
        data[:metas]
        |> List.first()
      end)

      cond do

        payload.joins == %{} && payload.leaves != %{}
        ->
      {:noreply, assign(socket, messages: join_messages ++ leave_messages, user_list: user_list)}


        payload.joins != %{} && payload.leaves == %{}
        ->
      {:noreply, assign(socket, messages: join_messages ++ leave_messages, user_list: user_list)}

        true ->
      {:noreply, assign(socket, user_list: user_list)}

    end
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: payload},
        socket
      ) do
    user_list =
      ChatWeb.Presence.list(socket.assigns.topic)
      |> Enum.map(fn {_username, data} ->
        data[:metas]
        |> List.first()
      end)

    {:noreply, assign(socket, user_list: user_list)}
  end

  def display_message(assigns, %{type: :system, uuid: uuid, content: content}) do
    ~H"""
    <p id={uuid}><em><%= content %></em></p>
    """
  end

  def display_message(assigns, %{uuid: uuid, content: content, username: username}) do
    ~H"""
    <p id={uuid}><strong><%= username<>": "%></strong><%= content %></p>
    """
  end
end

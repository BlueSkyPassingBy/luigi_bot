defmodule Luigi do
  @moduledoc """
  Documentation for `Luigi`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Luigi.hello()
      :world

  """
  def hello do
    :world
  end

  use Telegram.Bot
  use Agent

  @bot_username System.get_env("BOT_USERNAME")

  @menny_initial_value %{
    chef: %{
      name: "Luigi",
      id:  0
    },
    antepasto: "Left",
    principal: "Left",
    sobremesa: "Left",
    cafezinho: "Left"
  }

  @impl Telegram.Bot
  def handle_update(
    %{"message" => %{"text" => "/menny@" <> @bot_username, "chat" => %{"id" => chat_id}}},
    token) do

    # get agent
    menny = Agent.get(__MODULE__, & &1)

    # send msg
    Telegram.Api.request(token, "sendMessage",
      chat_id: chat_id,
      text: "*Antepasto*\n#{menny.antepasto}\n\n*Prato principal*\n#{menny.principal}\n\n*Sobremesa*\n#{menny.sobremesa}\n\n*Cafézinho*\n#{menny.cafezinho}",
      parse_mode: "MarkdownV2",
    )
  end

  def handle_update(
    %{"message" => %{"text" => text, "chat" => %{"id" => chat_id}, "message_id" => message_id}},
    token) do

    [command | argument_list] = String.split(text)

    menny_commands_keys = %{
      "/setmennyantepasto" => :antepasto,
      "/setmennyprincipal" => :principal,
      "/setmennysobremesa" => :sobremesa,
      "/setmennycafezinho" => :cafezinho
    }

    if Map.has_key?(menny_commands_keys, command) and length(argument_list) != 0 do
      argument = Enum.join(argument_list, " ")
      handle_menny_update(Map.get(menny_commands_keys, command), argument, chat_id, message_id, token)
    end

  end


  def handle_menny_update(key, value, chat_id, message_id, token) do
    if String.length(value) > 50 do
      Telegram.Api.request(token, "sendMessage",
        chat_id: chat_id,
        reply_to_message_id: message_id,
        text: "Limite de 50 caracteres blz? 👍"
      )
    else
      # update menny
      Agent.update(__MODULE__, & Map.put(&1, key, value))

      # Tell the user the update went ok
      Telegram.Api.request(token, "sendMessage",
        chat_id: chat_id,
        reply_to_message_id: message_id,
        text: "👍👍"
      )
    end
  end

  def handle_update(_update, _token) do
    # ignore unknown updates
    :ok
  end

  def start() do
    # get token
    token = System.get_env("BOT_TOKEN")
    # start an agent for storing menny
    Agent.start_link(fn -> @menny_initial_value end, name: __MODULE__)

    {:ok, _} = Supervisor.start_link(
      [{Telegram.Poller, bots: [{Luigi, token: token, max_bot_concurrency: 1_000}]}],
      strategy: :one_for_one
    )
  end

end

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

  @impl Telegram.Bot
  def handle_update(
    %{"message" => %{"text" => "/menny@sir_luigi_bot", "chat" => %{"id" => chat_id}, "message_id" => message_id}},
    token) do
    # send msg
    Telegram.Api.request(token, "sendMessage",
      chat_id: chat_id,
      text: "*Antepasto*\nLeft\n\n*Prato principal*\nLeft\n\n*Sobremesa*\nLeft",
      parse_mode: "MarkdownV2",
    )
  end

  def handle_update(_update, _token) do
    # ignore unknown updates
    :ok
  end

  def start() do
    token = System.get_env("BOT_TOKEN")

    {:ok, _} = Supervisor.start_link(
      [{Telegram.Poller, bots: [{Luigi, token: token, max_bot_concurrency: 1_000}]}],
      strategy: :one_for_one
    )
  end

end

defmodule BounceBack do
  alias BounceBack.Strategies

  @default_opts [
    max_retries: 5,
    strategy: :exponential_backoff,
    # milliseconds
    base_delay: 100,
    jitter: true
  ]

  defmacro retry(opts \\ [], do: block) do
    quote do
      opts = Keyword.merge(unquote(@default_opts), unquote(opts))
      execute_retry(fn -> unquote(block) end, opts, opts[:max_retries])
    end
  end

  def execute_retry(fun, opts, remaining_retries) do
    case fun.() do
      {:ok, result} ->
        {:ok, result}

      {:error, reason} when remaining_retries > 0 ->
        emit_retry_event(remaining_retries, reason)
        Strategies.wait(opts[:strategy], opts, opts[:max_retries] - remaining_retries)
        execute_retry(fun, opts, remaining_retries - 1)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp emit_retry_event(remaining, reason) do
    :telemetry.execute(
      [:bounce_back, :retry],
      %{remaining_retries: remaining},
      %{reason: reason}
    )
  end
end

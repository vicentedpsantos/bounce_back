defmodule BounceBack do
  alias BounceBack.Strategies

  @default_opts [
    max_retries: 5,
    strategy: :exponential_backoff,
    base_delay: 1000,
    jitter: true
  ]

  @doc """
  Retries a function according to the specified strategy and options.

  ## Options
      - `:max_retries` - The maximum number of retries. Defaults to 5.
      - `:strategy` - The retry strategy to use. Defaults to `:exponential_backoff`.
      - `:base_delay` - The base delay in milliseconds. Defaults to 1000.
      - `:jitter` - Whether to add randomization to the delay. Defaults to `true`.

  ## Examples
      iex> BounceBack.retry(fn -> might_fail() end, max_retries: 3)
      {:ok, result}

  """
  def retry(fun, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    retry_with_strategy(fun, opts, opts[:max_retries])
  end

  defp retry_with_strategy(fun, opts, remaining_retries) do
    case fun.() do
      {:ok, result} ->
        {:ok, result}

      {:error, reason} when remaining_retries > 0 ->
        emit_retry_event(remaining_retries, reason)
        Strategies.wait(opts[:strategy], opts, opts[:max_retries] - remaining_retries)
        retry_with_strategy(fun, opts, remaining_retries - 1)

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

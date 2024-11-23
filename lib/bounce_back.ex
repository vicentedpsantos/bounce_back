defmodule BounceBack do
  alias BounceBack.Strategies

  @default_opts [
    max_retries: 5,
    strategy: :exponential_backoff,
    retry_on: [],
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

      {:error, error} when remaining_retries > 0 ->
        emit_retry_event(remaining_retries, error)
        Strategies.wait(opts[:strategy], opts, opts[:max_retries] - remaining_retries)

        if should_retry?(error, opts[:retry_on]) do
          execute_retry(fun, opts, remaining_retries - 1)
        end

      {:error, error} ->
        {:error, error}
    end
  end

  defp should_retry?(_, []), do: true

  defp should_retry?(%struct_name{} = error, [_ | _] = retry_on)
       when is_list(retry_on) and is_struct(error),
       do: struct_name in retry_on

  defp should_retry?(error, retry_on)
       when is_list(retry_on) and is_binary(error),
       do: error in retry_on

  defp should_retry?(error, retry_on) when is_function(retry_on), do: retry_on.(error)

  defp emit_retry_event(remaining, error) do
    :telemetry.execute(
      [:bounce_back, :retry],
      %{remaining_retries: remaining},
      %{error: error}
    )
  end
end

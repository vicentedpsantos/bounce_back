defmodule BounceBack.Strategies do
  @moduledoc """
  Implements various retry strategies for BounceBack.
  """

  def wait(:linear, opts, attempt) do
    delay = opts[:base_delay] * attempt
    sleep_with_jitter(delay, Keyword.get(opts, :jitter, false))
    delay
  end

  def wait(:exponential_backoff, opts, attempt) do
    delay = opts[:base_delay] * :math.pow(2, attempt - 1)
    sleep_with_jitter(delay, Keyword.get(opts, :jitter, false))
  end

  defp sleep_with_jitter(delay, true) do
    jitter = delay * (:rand.uniform() - 0.5)
    delay = delay + jitter
    Process.sleep(trunc(delay))
    trunc(delay)
  end

  defp sleep_with_jitter(delay, false) do
    Process.sleep(trunc(delay))
    trunc(delay)
  end
end

defmodule BounceBack.Strategies do
  @moduledoc """
  Implements various retry strategies for BounceBack.
  """

  def wait(:linear, opts, attempt) do
    delay = opts[:base_delay] * attempt
    sleep_with_jitter(delay, opts[:jitter])
  end

  def wait(:exponential_backoff, opts, attempt) do
    delay = opts[:base_delay] * :math.pow(2, attempt - 1)
    sleep_with_jitter(delay, opts[:jitter])
  end

  defp sleep_with_jitter(delay, true) do
    # ±50% jitter
    jitter = delay * (:rand.uniform() - 0.5)
    Process.sleep(trunc(delay + jitter))
  end

  defp sleep_with_jitter(delay, false) do
    Process.sleep(trunc(delay))
  end
end

defmodule BounceBack.Telemetry do
  @moduledoc """
  Telemetry events for BounceBack.
  """

  def attach_default_handler do
    :telemetry.attach(
      "bounce-back-default-handler",
      [:bounce_back, :retry],
      &handle_retry_event/4,
      nil
    )
  end

  defp handle_retry_event(_event, measurements, metadata, _config) do
    IO.puts("Retry event: #{inspect(measurements)}, Reason: #{inspect(metadata[:reason])}")
  end
end

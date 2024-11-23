defmodule BounceBack.TelemetryTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  alias BounceBack.Telemetry, as: Subject

  describe "attach_default_handler/0" do
    setup do
      :telemetry.detach("bounce-back-default-handler")
      :ok
    end

    test "attaches the default handler" do
      Subject.attach_default_handler()

      handlers = :telemetry.list_handlers([:bounce_back, :retry])

      assert Enum.any?(handlers, fn handler ->
               handler.id == "bounce-back-default-handler"
             end)
    end
  end

  describe "handle_retry_event/4" do
    setup do
      Subject.attach_default_handler()

      on_exit(fn -> :telemetry.detach("bounce-back-default-handler") end)
    end

    test "prints retry event details to the console" do
      output =
        capture_io(fn ->
          :telemetry.execute(
            [:bounce_back, :retry],
            %{retry_count: 3},
            %{reason: :timeout}
          )
        end)

      assert output =~ "Retry event: %{retry_count: 3}, Reason: :timeout"
    end
  end
end

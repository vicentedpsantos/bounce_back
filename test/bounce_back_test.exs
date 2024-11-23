defmodule BounceBackTest do
  use ExUnit.Case
  import BounceBack

  test "retries a block until success" do
    success_after = 3
    call_count = :erlang.make_ref()
    Process.put(call_count, 0)

    retry max_retries: 5 do
      count = Process.get(call_count)
      Process.put(call_count, count + 1)

      if count >= success_after do
        {:ok, "Success"}
      else
        {:error, "Failure"}
      end
    end

    assert Process.get(call_count) == success_after + 1
  end

  test "returns error if retries are exhausted" do
    result =
      retry max_retries: 3 do
        {:error, "Always fails"}
      end

    assert result == {:error, "Always fails"}
  end
end

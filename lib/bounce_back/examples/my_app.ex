defmodule BounceBack.Examples.MyApp do
  alias BounceBack

  def run_task do
    task = fn ->
      if :rand.uniform(10) > 5 do
        {:ok, "Success"}
      else
        {:error, "Random failure"}
      end
    end

    case BounceBack.retry(task, strategy: :exponential_backoff, max_retries: 3, base_delay: 200) do
      {:ok, result} -> IO.puts("Task succeeded with result: #{result}")
      {:error, reason} -> IO.puts("Task failed with reason: #{reason}")
    end
  end
end

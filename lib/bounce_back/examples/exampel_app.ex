defmodule BounceBack.Examples.ExampleApp do
  import BounceBack

  def exponential_backoff_task do
    retry strategy: :exponential_backoff, max_retries: 3, base_delay: 300 do
      if :rand.uniform(10) > 7 do
        {:ok, "Success"}
      else
        {:error, "Random failure"}
      end
    end
  end

  def linear_task do
    retry strategy: :linear, max_retries: 3, base_delay: 300 do
      if :rand.uniform(10) > 7 do
        {:ok, "Success"}
      else
        {:error, "Random failure"}
      end
    end
  end

  def exponential_backoff_with_jitter_task do
    retry strategy: :linear, max_retries: 3, base_delay: 300, jitter: true do
      if :rand.uniform(10) > 7 do
        {:ok, "Success"}
      else
        {:error, "Random failure"}
      end
    end
  end
end

defmodule BounceBack.Examples.ExampleApp do
  import BounceBack

  defmodule MyError do
    defstruct [:message]
  end

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

  def retry_on_errors do
    retry max_retries: 10, retry_on: [MyError] do
      if :rand.uniform(10) > 7 do
        IO.puts("This will not try again")
        {:error, "This will not try again"}
      else
        IO.puts("This will try again")
        {:error, %MyError{message: "This will try again"}}
      end
    end
  end

  def retry_on_function do
    retry max_retries: 10,
          retry_on: fn error -> error == "this should be retried" end do
      if :rand.uniform(10) > 7 do
        IO.puts("This will not try again")
        {:error, "This will not try again"}
      else
        IO.puts("This will try again")
        {:error, "this should be retried"}
      end
    end
  end
end

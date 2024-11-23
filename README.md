# BounceBack ♻️

[![BounceBack](https://img.shields.io/hexpm/v/kase.svg)](https://hex.pm/packages/bounce_back/0.2.0)

BounceBack is an Elixir library that provides flexible retry mechanisms with customizable strategies for handling retries in the event of failures. It allows you to easily implement retry logic in your applications using a variety of strategies, such as exponential backoff and linear delay, with options for jitter to avoid congestion during retries.

## Features

- **Retry Mechanism**: Automatically retries failed operations with customizable retry policies.
- **Multiple Strategies**: Built-in strategies like exponential backoff and linear delay, with the ability to extend.
- **Customizable Options**: Control the number of retries, delay between retries, and more.
- **Telemetry Integration**: Hooks for monitoring retry attempts and failures using Elixir's `:telemetry`.
- **Error Handling**: Retry based on specific error types or conditions.

## Installation

Add `bounce_back` to your list of dependencies in `mix.exs`:

```elixir
defp deps do
  [
    {:bounce_back, "~> 0.1"}
  ]
end
```

Then, run the following command to install the dependency:

```bash
mix deps.get
```

## Usage

### Basic Retry Example

You can use the `BounceBack.retry/2` macro to wrap any operation you want to retry. Here's an example that retries a function that can fail, using the default options:

```elixir
defmodule MyApp.Example do
  import BounceBack

  def some_function do
    retry do
      # Your code that might fail
      IO.puts("Attempting operation...")
      {:error, :something_went_wrong}
    end
  end
end
```

In this example, the operation will be retried up to 5 times with an exponential backoff strategy if it fails.

### Customizing Retry Behavior

You can provide custom options to configure how retries are performed. The options include:

- `:max_retries`: The maximum number of retry attempts (default: `5`).
- `:strategy`: The retry strategy (`:exponential_backoff`, `:linear`), with default set to `:exponential_backoff`.
- `:retry_on`: A list of error types or a function that should trigger a retry. If empty, all errors will trigger a retry (default: `[]`).
- `:base_delay`: The base delay in milliseconds between retries (default: `100`).
- `:jitter`: A boolean to enable/disable jitter on the delay (default: `true`).

#### Example with custom options:

```elixir
defmodule MyApp.Example do
  import BounceBack

  def some_function do
    retry(max_retries: 3, strategy: :linear, base_delay: 200, jitter: false) do
      IO.puts("Attempting operation...")
      {:error, :temporary_error}
    end
  end
end
```

### Retry Based on Error Types

You can configure `:retry_on` to specify which error types or conditions should trigger a retry:

```elixir
defmodule MyApp.Example do
  import BounceBack

  def some_function do
    retry(retry_on: [:temporary_error]) do
      IO.puts("Attempting operation...")
      {:error, :temporary_error}
    end
  end
end
```

In this case, the operation will only retry if the error is `:temporary_error`.

### Telemetry Events

BounceBack integrates with Elixir's `:telemetry` system to emit events each time a retry is attempted. You can attach a default handler to listen for retry events:

```elixir
BounceBack.Telemetry.attach_default_handler()
```

This will log the retry attempts and errors when a retry event occurs.

#### Custom Telemetry Handler

You can also define your own handler for retry events. For example:

```elixir
:telemetry.attach(
  "my-custom-handler",
  [:bounce_back, :retry],
  fn _event, measurements, metadata, _config ->
    IO.puts("Retry attempt: #{inspect(measurements)}, Reason: #{inspect(metadata[:error])}")
  end,
  nil
)
```

## Retry Strategies

BounceBack comes with two built-in retry strategies:

- **Linear**: The delay between retries increases linearly with each attempt.
- **Exponential Backoff**: The delay doubles with each retry attempt, starting from the base delay.

You can define your own strategy by implementing a `wait/3` function in the `BounceBack.Strategies` module.

### Telemetry Events for Retry Attempts

Whenever a retry event occurs, BounceBack emits telemetry events with the following measurements:

- `remaining_retries`: The number of retries remaining before giving up.
- `error`: The reason for the failure that triggered the retry.

## License

BounceBack is released under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

This README provides an overview of how to use the `BounceBack` library, including examples and configuration options.

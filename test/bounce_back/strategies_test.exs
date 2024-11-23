defmodule BounceBack.StrategiesTest do
  use ExUnit.Case, async: true
  alias BounceBack.Strategies, as: Subject

  @base_delay 100

  describe "Linear backoff" do
    test "increases delay linearly" do
      for attempt <- 1..3 do
        delay = Subject.wait(:linear, [base_delay: @base_delay], attempt)
        expected_delay = @base_delay * attempt
        assert delay == expected_delay
      end
    end
  end

  describe "Exponential backoff" do
    test "increases delay exponentially" do
      for attempt <- 1..3 do
        delay = Subject.wait(:exponential_backoff, [base_delay: @base_delay], attempt)
        expected_delay = @base_delay * :math.pow(2, attempt - 1)
        assert delay == trunc(expected_delay)
      end
    end
  end

  describe "Jitter handling" do
    test "applies jitter to delay when enabled" do
      attempt = 1

      delay_without_jitter =
        Subject.wait(:exponential_backoff, [base_delay: @base_delay, jitter: false], attempt)

      delay_with_jitter =
        Subject.wait(:exponential_backoff, [base_delay: @base_delay, jitter: true], attempt)

      assert delay_with_jitter != delay_without_jitter
      assert delay_with_jitter in (delay_without_jitter - 50)..(delay_without_jitter + 50)
    end

    test "does not apply jitter when jitter is false" do
      attempt = 1

      delay =
        Subject.wait(:exponential_backoff, [base_delay: @base_delay, jitter: false], attempt)

      expected_delay = @base_delay * :math.pow(2, attempt - 1)
      assert delay == trunc(expected_delay)
    end
  end

  describe "Correct delay calculation" do
    test "linear backoff delay is correct" do
      attempt = 2
      delay = Subject.wait(:linear, [base_delay: @base_delay], attempt)
      assert delay == @base_delay * attempt
    end

    test "exponential backoff delay is correct" do
      attempt = 3
      delay = Subject.wait(:exponential_backoff, [base_delay: @base_delay], attempt)
      expected_delay = @base_delay * :math.pow(2, attempt - 1)
      assert delay == trunc(expected_delay)
    end
  end
end

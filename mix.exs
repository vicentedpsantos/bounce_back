defmodule BounceBack.MixProject do
  use Mix.Project

  def project do
    [
      app: :bounce_back,
      version: "0.2.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "BounceBack",
        extras: ["README.md", "LICENSE"]
      ],
      description: "A simple library for retrying failed operations.",
      package: package_info()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:telemetry, "~> 0.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package_info do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      licenses: ["MIT"],
      maintainers: ["Vicente Santos"],
      links: %{"GitHub" => "https://github.com/vicentedpsantos/bounce_back"}
    ]
  end
end

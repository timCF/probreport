defmodule Probreport.Mixfile do
  use Mix.Project

  def project do
    [app: :probreport,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [
                      :logger,
                      :statistics,
                      :csvex,
                      :erlmath,
                      :maybe,
                      :exroul,
                      :erlng,
                      :exkeno,
                    ],
     mod: {Probreport, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:statistics, github: "msharp/elixir-statistics"},
      {:csvex, github: "timCF/csvex"},
      {:erlmath, github: "timCF/erlmath"},
      {:maybe, github: "timCF/maybe"},
      {:exroul, github: "timCF/exroul"},
      {:erlng, github: "timCF/erlng"},
      {:exkeno, github: "timCF/exkeno"},
    ]
  end
end

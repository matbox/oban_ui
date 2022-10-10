defmodule ObanUi.MixProject do
  use Mix.Project

  def project do
    [
      app: :oban_ui,
      version: "0.1.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :phoenix]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.6.13"},
      {:phoenix_html, "~> 3.2.0"},
      {:phoenix_live_view, "~> 0.18.2"},
      {:surface, "~> 0.9.1"},
      {:gettext, "~> 0.20.0"},
      {:phoenix_ecto, "~> 4.4.0"},
      # Pagination
      {:scrivener_ecto, "~> 2.7.0"}
    ]
  end
end

defmodule SimpleSat.MixProject do
  use Mix.Project

  @description "A simple, dependency free boolean satisfiability solver."
  @version "0.1.2"

  def project do
    [
      app: :simple_sat,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      description: @description,
      source_url: "https://github.com/ash-project/simple_sat",
      homepage_url: "https://github.com/ash-project/simple_sat",
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  defp docs() do
    [
      before_closing_head_tag: fn type ->
        if type == :html do
          """
          <script>
            if (location.hostname === "hexdocs.pm") {
              var script = document.createElement("script");
              script.src = "https://plausible.io/js/script.js";
              script.setAttribute("defer", "defer")
              script.setAttribute("data-domain", "ashhexdocs")
              document.head.appendChild(script);
            }
          </script>
          """
        end
      end
    ]
  end

  defp package do
    [
      name: :simple_sat,
      licenses: ["MIT"],
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      links: %{
        GitHub: "https://github.com/ash-project/simple_sat",
        Discord: "https://discord.gg/HTHRaaVPUc",
        Website: "https://ash-hq.org",
        Forum: "https://elixirforum.com/c/elixir-framework-forums/ash-framework-forum"
      }
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
      # Dev/Test dependencies
      {:ex_doc, github: "elixir-lang/ex_doc", only: [:dev, :test], runtime: false},
      {:ex_check, "~> 0.12", only: [:dev, :test]},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:sobelow, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:git_ops, "~> 2.5", only: [:dev, :test]},
      {:doctor, "~> 0.21", only: [:dev, :test]}
    ]
  end
end

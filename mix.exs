defmodule Circuits.UART.MixProject do
  use Mix.Project

  @version "1.5.3"
  @source_url "https://github.com/elixir-circuits/circuits_uart"

  def project do
    [
      app: :circuits_uart,
      version: @version,
      elixir: "~> 1.6",
      description: description(),
      package: package(),
      source_url: @source_url,
      compilers: [:elixir_make | Mix.compilers()],
      make_targets: ["all"],
      make_clean: ["clean"],
      make_executable: make_executable(),
      make_makefile: "src/Makefile",
      make_error_message: make_error_message(),
      make_precompiler: {:nif, CCPrecompiler},
      make_precompiler_url:
        "https://github.com/m0rt3nlund/circuits_uart/releases/download/v#{@version}/@{artefact_filename}",
      make_precompiler_filename: "nif",
      make_precompiler_nif_versions: [
        versions: ["2.16"],
        fallback_version: fn opts ->
          hd(nif_versions(opts))
        end
      ],
      make_precompiler_priv_paths: ["nif.*"],
      make_precompiler_unavailable_target: :compile,
      cc_precompiler: cc_precompiler(),
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      dialyzer: dialyzer(),
      deps: deps(),
      preferred_cli_env: %{
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs
      }
    ]
  end

  def application, do: []

  defp description do
    "Discover and use UARTs and serial ports in Elixir"
  end

  defp package do
    %{
      files: [
        "lib",
        "src/*.[ch]",
        "src/ei_copy/*.[ch]",
        "src/Makefile",
        "test",
        "mix.exs",
        "README.md",
        "LICENSE",
        "CHANGELOG.md",
        "checksum.exs"
      ],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    }
  end

  defp deps do
    [
      {:elixir_make, "~> 0.6", runtime: false},
      {:ex_doc, "~> 0.22", only: :docs, runtime: false},
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.2", only: :dev, runtime: false},
      {:cc_precompiler, "~> 0.1.10"}
    ]
  end

  defp dialyzer() do
    [
      flags: [:missing_return, :extra_return, :unmatched_returns, :error_handling, :underspecs],
      list_unused_filters: true
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp nif_versions(opts) do
    if String.contains?(opts.target, "windows") or
         String.contains?(opts.target, "darwin") do
      ["2.16"]
    else
      ["2.15"]
    end
  end

  defp make_executable do
    case :os.type() do
      {:win32, _} ->
        "mingw32-make"

      _ ->
        :default
    end
  end

  @windows_mingw_error_msg """
  You may need to install mingw-w64 and make sure that it is in your PATH. Test this by
  running `gcc --version` on the command line.

  If you do not have mingw-w64, one method to install it is by using
  Chocolatey. See http://chocolatey.org to install Chocolatey and run the
  following from and command prompt with administrative privileges:

  `choco install mingw`
  """

  defp make_error_message do
    case :os.type() do
      {:win32, _} -> @windows_mingw_error_msg
      _ -> :default
    end
  end

  defp cc_precompiler do
    [
      cleanup: "clean",
      compilers: %{
        {:unix, :linux} => %{
          "x86_64-linux-gnu" => "x86_64-linux-gnu-"
        },
        {:win32, :nt} => %{
          "x86_64-w64-mingw32-gcc" => {"gcc", "gcc"}
        }
      }
    ]
  end
end

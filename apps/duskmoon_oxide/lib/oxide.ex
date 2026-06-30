defmodule Oxide do
  @moduledoc """
  Elixir bindings for Tailwind CSS Oxide — the Rust-powered content scanner.

  Oxide scans source files in parallel to extract Tailwind CSS candidate
  class names. It powers the fast incremental rebuilds in Tailwind CSS v4.

  ## Usage

  Create a scanner, scan for candidates, then feed them to the Tailwind
  compiler to generate CSS.

      # Create a scanner for your project
      scanner = Oxide.new(sources: [%{base: "lib/", pattern: "**/*.heex"}])

      # Full scan — returns all candidates found across all files
      candidates = Oxide.scan(scanner)
      # ["flex", "sm:bg-red-500", "hover:text-white", ...]

      # Incremental scan — only returns NEW candidates from changed files
      new = Oxide.scan_files(scanner, [%{file: "lib/app_web/live/page.ex", extension: "ex"}])

  For one-off extraction without a scanner:

      candidates = Oxide.extract(~s(class="flex bg-red-500"), "html")
      # [%{value: "class", position: 0}, %{value: "flex", position: 7}, ...]
  """

  defmodule Source do
    @moduledoc "Source entry for scanner configuration."
    @type t :: %__MODULE__{base: String.t(), pattern: String.t(), negated: boolean()}
    defstruct base: "", pattern: "", negated: false
  end

  defmodule Glob do
    @moduledoc "Glob entry returned by the scanner."
    @type t :: %__MODULE__{base: String.t(), pattern: String.t()}
    defstruct base: "", pattern: ""
  end

  defmodule Changed do
    @moduledoc "Changed content for incremental scanning."
    @type t :: %__MODULE__{
            file: String.t() | nil,
            content: String.t() | nil,
            extension: String.t()
          }
    defstruct file: nil, content: nil, extension: ""
  end

  defmodule Candidate do
    @moduledoc "Extracted candidate with byte position."
    @type t :: %__MODULE__{value: String.t(), position: non_neg_integer()}
    defstruct value: "", position: 0
  end

  @doc """
  Create a new scanner.

  ## Options

    * `:sources` — list of source entries, each a map or `%Oxide.Source{}`
      with `:base`, `:pattern`, and optional `:negated` (default `false`)

  ## Examples

      scanner = Oxide.new(sources: [
        %{base: "lib/", pattern: "**/*.{ex,heex}"},
        %{base: "assets/", pattern: "**/*.vue"}
      ])
  """
  @spec new(keyword()) :: reference()
  def new(opts \\ []) do
    sources =
      opts
      |> Keyword.get(:sources, [])
      |> Enum.map(fn
        %Source{} = s -> s
        map -> struct!(Source, Map.put_new(map, :negated, false))
      end)

    Oxide.Native.new_scanner(sources)
  end

  @doc """
  Full scan — walks filesystem, extracts all candidates.

  Returns a sorted, deduplicated list of candidate strings.
  Subsequent calls only return candidates from files changed since the last scan.
  """
  @spec scan(reference()) :: [String.t()]
  def scan(scanner) do
    Oxide.Native.scan(scanner)
  end

  @doc """
  Incremental scan — extract candidates from specific changed files.

  Returns only NEW candidates not seen in previous scans.
  This is what makes HMR fast.

  ## Examples

      new_candidates = Oxide.scan_files(scanner, [
        %{file: "lib/app_web/live/page.ex", extension: "ex"}
      ])

      # Or with inline content (no filesystem read):
      new_candidates = Oxide.scan_files(scanner, [
        %{content: ~s(class="flex mt-4"), extension: "html"}
      ])
  """
  @spec scan_files(reference(), [map()]) :: [String.t()]
  def scan_files(scanner, changed) do
    changed =
      Enum.map(changed, fn
        %Changed{} = c -> c
        map -> struct!(Changed, map)
      end)

    Oxide.Native.scan_files(scanner, changed)
  end

  @doc """
  Extract candidates with byte positions from a string.

  Stateless — does not require a scanner. Useful for one-off extraction.

  ## Examples

      candidates = Oxide.extract(~s(class="flex bg-red-500"), "html")
      [%Oxide.Candidate{value: "class", position: 0}, ...]
  """
  @spec extract(String.t(), String.t()) :: [Candidate.t()]
  def extract(content, extension) do
    Oxide.Native.get_candidates(content, extension)
  end

  @doc """
  Get all files discovered by the scanner.
  """
  @spec files(reference()) :: [String.t()]
  def files(scanner) do
    Oxide.Native.get_files(scanner)
  end

  @doc """
  Get generated glob patterns for setting up file watchers.
  """
  @spec globs(reference()) :: [Glob.t()]
  def globs(scanner) do
    Oxide.Native.get_globs(scanner)
  end
end

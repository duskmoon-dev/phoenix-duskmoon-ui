defmodule DuskmoonBundler.Pipeline.Result do
  @moduledoc """
  Compiled output returned by `DuskmoonBundler.Pipeline.compile/3`.

  Pipeline results carry JavaScript or CSS code plus optional side-channel data
  used by the dev server and production builder, such as sourcemaps, extracted
  CSS, SFC block hashes, and warnings from framework compilers.
  """

  defmodule Hashes do
    @moduledoc """
    Content hashes for framework single-file component blocks.

    The dev server uses these hashes to distinguish template, script, and style
    changes so HMR can choose the narrowest safe update.
    """

    defstruct template: nil, style: nil, script: nil

    @type t :: %__MODULE__{
            template: String.t() | nil,
            style: String.t() | nil,
            script: String.t() | nil
          }
  end

  defstruct code: "", type: :js, sourcemap: nil, css: nil, hashes: nil, warnings: []

  @type type :: :js | :css

  @type t :: %__MODULE__{
          code: String.t(),
          type: type(),
          sourcemap: String.t() | nil,
          css: String.t() | nil,
          hashes: Hashes.t() | nil,
          warnings: [term()]
        }
end

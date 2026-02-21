defmodule PhoenixDuskmoon do
  @moduledoc """
  Provides Duskmoon UI for Phoenix project.

  **v9**: Uses `@duskmoon-dev/core` CSS design system and HTML Custom Elements.

  Requires `tailwindcss >= 4.0`

  ## Install in deps

  Add deps in `mix.exs`

      {:phoenix_duskmoon, "~> 9.0"}

  Install npm packages:

      npm install @duskmoon-dev/core @duskmoon-dev/elements

  ## Setup in `Phoenix` project

  - In `app_web.ex`

  ```elixir
      defp html_helpers do
        quote do
          # import all duskmoon ui component
          use PhoenixDuskmoon.Component
          # import all duskmoon ui css art component
          use PhoenixDuskmoon.CssArt
          ...
        end
      end
  ```

  - In `app.css`

  ```css
      @source "../js/**/*.js";
      @source '../../lib/**/*.exs';
      @source '../../lib/**/*.ex';

      @import "tailwindcss";
      @plugin "@duskmoon-dev/core/plugin";
  ```

  """
end

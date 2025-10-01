defmodule PhoenixDuskmoon do
  @moduledoc """
  Provides Duskmoon UI for Phoenix project.

  Require `tailwindcss >= 4.0` and `duskmoonui >= 5.0`

  ## Install in deps

  Add deps in `mix.exs`

      {:phoenix_duskmoon, "~> 6.0"}

  ## Setup in `Phoenix` project

  - In `app_web.ex`

  ```

      defp html_helpers do
        quote do
          # import all duskmoon ui component
          use PhoenixDuskmoon.Component
          # import all duskmoon ui fun component
          use PhoenixDuskmoon.Fun
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
      @plugin "@tailwindcss/typography";
      @plugin "duskmoonui";
      @import "phoenix_duskmoon/theme";
      @import "phoenix_duskmoon/components";
  ```

  """
end

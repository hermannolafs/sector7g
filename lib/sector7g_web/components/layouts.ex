defmodule Sector7gWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use Sector7gWeb, :controller` and
  `use Sector7gWeb, :live_view`.
  """
  use Sector7gWeb, :html

  embed_templates "layouts/*"
end

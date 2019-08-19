defmodule <%= inspect context.module %>Test do
  use <%= inspect context.base_module %>.DataCase

  import <%= inspect context.base_module %>.Factory

  alias <%= inspect context.module %>
end

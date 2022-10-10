defmodule ObanUi.Router do
  defmacro oban_web(path) do
    quote bind_quoted: binding() do
      scope path, alias: false, as: false do
        live "/", ObanUi.Live.Jobs.Index
      end
    end
  end
end

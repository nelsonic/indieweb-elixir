defmodule IndieWeb do
  @moduledoc """
  The IndieWeb is a people-focused alternative to the "corporate web". 
  
  This library provides common facilities for handling interactions and 
  logic in the IndieWeb space. For more information; check out the open
  Wiki over at <https://indieweb.org>.

  ## Configuration
  This library makes a lot of network and caching requests. In order to
  keep the core implementation light, `indieweb` provides a few adapters
  that one can set as the default one of choice for the library to use.

  ### Adapters
  You can update the accompanying option for it by checking the module's
  documentation:

  * `IndieWeb.Http.Adapter`
  * `IndieWeb.Cache.Adapter`

  ### Default Adapters
  This library ships with support for `HTTPotion` via `IndieWeb.Http.Adapters.HTTPotion` and
  `Cachex` via `IndieWeb.Cache.Adapters.Cachex`.
  """
end

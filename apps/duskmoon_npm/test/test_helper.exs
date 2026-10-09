{:ok, _apps} = Application.ensure_all_started(:http_fetch)
ExUnit.start()

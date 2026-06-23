defmodule DuskmoonBundler.CacheTest do
  use ExUnit.Case, async: false

  setup do
    DuskmoonBundler.Cache.clear()
    :ok
  end

  test "get returns nil on miss" do
    assert DuskmoonBundler.Cache.get("/app.ts", 12345) == nil
  end

  test "put and get round-trip" do
    entry = %{
      code: "const x = 1",
      sourcemap: nil,
      css: nil,
      content_type: "application/javascript"
    }

    DuskmoonBundler.Cache.put("/app.ts", 100, entry)
    assert DuskmoonBundler.Cache.get("/app.ts", 100) == entry
  end

  test "get_file returns an entry regardless of mtime" do
    entry = %{
      code: "const x = 1",
      sourcemap: nil,
      css: nil,
      content_type: "application/javascript"
    }

    DuskmoonBundler.Cache.put("/app.ts", 100, entry)
    assert DuskmoonBundler.Cache.get_file("/app.ts") == entry
  end

  test "different mtime is a miss" do
    entry = %{
      code: "const x = 1",
      sourcemap: nil,
      css: nil,
      content_type: "application/javascript"
    }

    DuskmoonBundler.Cache.put("/app.ts", 100, entry)
    assert DuskmoonBundler.Cache.get("/app.ts", 101) == nil
  end

  test "evict removes all entries for a path" do
    entry = %{code: "v1", sourcemap: nil, css: nil, content_type: "application/javascript"}
    DuskmoonBundler.Cache.put("/app.ts", 100, entry)
    DuskmoonBundler.Cache.put("/app.ts", 101, %{entry | code: "v2"})
    DuskmoonBundler.Cache.evict("/app.ts")
    assert DuskmoonBundler.Cache.get("/app.ts", 100) == nil
    assert DuskmoonBundler.Cache.get("/app.ts", 101) == nil
  end

  test "evict_file removes both plain and ?import entries" do
    entry = %{code: "v1", sourcemap: nil, css: nil, content_type: "text/css"}

    import_entry = %{
      code: "import_v1",
      sourcemap: nil,
      css: nil,
      content_type: "application/javascript"
    }

    DuskmoonBundler.Cache.put("/style.css", 100, entry)
    DuskmoonBundler.Cache.put("/style.css?import", 100, import_entry)
    DuskmoonBundler.Cache.evict_file("/style.css")
    assert DuskmoonBundler.Cache.get("/style.css", 100) == nil
    assert DuskmoonBundler.Cache.get("/style.css?import", 100) == nil
  end
end

defmodule NPM.TarballTest do
  use ExUnit.Case, async: true

  test "scopes the pool timeout under Finch for Req 0.7 and later" do
    options = NPM.Tarball.__request_options__("0.7.0")

    assert options[:finch][:pool_timeout] == 120_000
    refute Keyword.has_key?(options, :pool_timeout)
  end

  test "keeps the top-level pool timeout for older Req versions" do
    options = NPM.Tarball.__request_options__("0.6.3")

    assert options[:pool_timeout] == 120_000
    refute Keyword.has_key?(options, :finch)
  end
end

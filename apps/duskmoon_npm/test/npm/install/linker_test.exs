defmodule NPM.Install.LinkerTest do
  use ExUnit.Case, async: true

  alias NPM.Install.Linker

  describe "__parent_entry_version__/1" do
    test "accepts resolver flat entries and lockfile entries" do
      assert Linker.__parent_entry_version__("1.2.3") == "1.2.3"
      assert Linker.__parent_entry_version__(%{version: "1.2.3"}) == "1.2.3"
      assert Linker.__parent_entry_version__(%{"version" => "1.2.3"}) == "1.2.3"
      assert Linker.__parent_entry_version__(%{}) == nil
    end
  end

  test "nested linking accepts resolver flat output without matching parents" do
    NPM.Resolver.clear_cache()

    assert :ok =
             Linker.link_nested(
               %{"nested-dep" => :nested},
               %{"parent-dep" => "1.2.3"},
               System.tmp_dir!()
             )
  end
end

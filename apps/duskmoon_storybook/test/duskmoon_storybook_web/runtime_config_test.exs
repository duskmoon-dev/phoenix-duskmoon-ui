defmodule DuskmoonStorybookWeb.RuntimeConfigTest do
  use ExUnit.Case, async: false

  @config_dir Path.expand("../../../../config", __DIR__)

  setup do
    names = ~w(HOST PHX_SERVER SECRET_KEY_BASE PORT)
    original = Map.new(names, &{&1, System.get_env(&1)})
    Enum.each(names, &System.delete_env/1)

    on_exit(fn ->
      Enum.each(original, fn
        {name, nil} -> System.delete_env(name)
        {name, value} -> System.put_env(name, value)
      end)
    end)

    :ok
  end

  test "production HOST overrides only the endpoint URL host" do
    System.put_env("HOST", "duskmoon-storybook.gsmlg.org")
    endpoint = production_endpoint()

    assert Map.new(endpoint[:url]) == %{
             host: "duskmoon-storybook.gsmlg.org",
             port: 443,
             scheme: "https"
           }

    refute Keyword.has_key?(endpoint, :check_origin)
    refute Keyword.has_key?(endpoint, :secret_key_base)
  end

  test "production keeps the existing public hostname when HOST is absent" do
    assert Map.new(production_endpoint()[:url]) == %{
             host: "duskmoon-storybook.gsmlg.dev",
             port: 443,
             scheme: "https"
           }
  end

  test "HOST combines with existing server, HTTP port and secret configuration" do
    System.put_env(%{
      "HOST" => "storybook.example.test",
      "PHX_SERVER" => "true",
      "PORT" => "4080",
      "SECRET_KEY_BASE" => String.duplicate("runtime-config-test", 4)
    })

    endpoint = production_endpoint()

    assert endpoint[:url][:host] == "storybook.example.test"
    assert endpoint[:server]
    assert endpoint[:http][:port] == 4080
    assert endpoint[:secret_key_base] == System.get_env("SECRET_KEY_BASE")
    refute Keyword.has_key?(endpoint, :check_origin)
  end

  defp production_endpoint do
    @config_dir
    |> Path.join("prod.exs")
    |> Config.Reader.read!(env: :prod)
    |> Config.Reader.merge(Config.Reader.read!(Path.join(@config_dir, "runtime.exs"), env: :prod))
    |> Keyword.fetch!(:duskmoon_storybook)
    |> Keyword.fetch!(DuskmoonStorybookWeb.Endpoint)
  end
end

defmodule Storybook.DataEntry.Cascader do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Cascader.dm_cascader/1
  def description, do: "Cascading multi-panel select for hierarchical data."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "cas-default",
          placeholder: "Select location...",
          options: [
            %{value: "asia", label: "Asia", children: [
              %{value: "cn", label: "China", children: [
                %{value: "bj", label: "Beijing"},
                %{value: "sh", label: "Shanghai"}
              ]},
              %{value: "jp", label: "Japan"}
            ]},
            %{value: "eu", label: "Europe", children: [
              %{value: "uk", label: "UK"},
              %{value: "de", label: "Germany"}
            ]}
          ]
        }
      },
      %Variation{
        id: :with_path,
        attributes: %{
          id: "cas-path",
          options: [
            %{value: "asia", label: "Asia", children: [
              %{value: "cn", label: "China", children: [
                %{value: "bj", label: "Beijing"},
                %{value: "sh", label: "Shanghai"}
              ]}
            ]}
          ],
          selected_path: ["asia", "cn", "bj"]
        }
      },
      %Variation{
        id: :open_panels,
        attributes: %{
          id: "cas-open",
          options: [
            %{value: "asia", label: "Asia", children: [
              %{value: "cn", label: "China", children: [
                %{value: "bj", label: "Beijing"}
              ]},
              %{value: "jp", label: "Japan"}
            ]},
            %{value: "eu", label: "Europe"}
          ],
          selected_path: ["asia", "cn"],
          open: true,
          clearable: true
        }
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {nil, "Default"},
          {"sm", "SM"},
          {"lg", "LG"}
        ],
        default: nil
      },
      %{
        id: :variant,
        label: "Variant",
        type: :select,
        options: [
          {nil, "Default"},
          {"outlined", "Outlined"},
          {"filled", "Filled"}
        ],
        default: nil
      },
      %{
        id: :searchable,
        label: "Searchable",
        type: :boolean,
        default: false
      },
      %{
        id: :clearable,
        label: "Clearable",
        type: :boolean,
        default: false
      },
      %{
        id: :disabled,
        label: "Disabled",
        type: :boolean,
        default: false
      },
      %{
        id: :loading,
        label: "Loading",
        type: :boolean,
        default: false
      }
    ]
  end
end

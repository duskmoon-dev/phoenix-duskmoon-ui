import { describe, expect, test } from "bun:test";
import { pathOf, setAt, collectValues } from "../../assets/js/react_form/values.js";

describe("React form JSON values", () => {
  test("supports nested names and preserves JSON types", () => {
    let values = {};
    values = setAt(values, ["profile", "city"], "Shanghai");
    values = setAt(values, "enabled", false);
    values = setAt(values, "seats", 0);
    expect(pathOf("profile[city]")).toEqual(["profile", "city"]);
    expect(values).toEqual({ profile: { city: "Shanghai" }, enabled: false, seats: 0 });
  });

  test("collects native inputs without FormData coercion", () => {
    const input = (name, value, type = "text") => ({ name, value, type, checked: value, multiple: false });
    expect(collectValues([input("name", "Ada"), input("active", false, "checkbox"), input("seats", "2", "number")]))
      .toEqual({ name: "Ada", active: false, seats: 2 });
  });

  test("collects explicitly named checkbox groups as selected-value arrays", () => {
    expect(collectValues([
      { name: "tool_names[]", type: "checkbox", value: "file.read", checked: true },
      { name: "tool_names[]", type: "checkbox", value: "file.write", checked: false },
      { name: "tool_names[]", type: "checkbox", value: "file.search", checked: true },
      { name: "enabled", type: "checkbox", value: "on", checked: false },
    ])).toEqual({ tool_names: ["file.read", "file.search"], enabled: false });
  });

  test("keeps nested checkbox groups separate and includes empty groups", () => {
    expect(collectValues([
      { name: "agent[toolset_ids][]", type: "checkbox", value: "tools", checked: false },
      { name: "agent[toolset_ids][]", type: "checkbox", value: "skills", checked: true },
      { name: "agent[skill_ids][]", type: "checkbox", value: "read", checked: false },
      { name: "other[toolset_ids][]", type: "checkbox", value: "other", checked: true },
    ])).toEqual({ agent: { toolset_ids: ["skills"], skill_ids: [] }, other: { toolset_ids: ["other"] } });
  });

  test("a single [] checkbox remains an array while ordinary checkboxes remain booleans", () => {
    expect(collectValues([
      { name: "tool_names[]", type: "checkbox", value: "file.read", checked: true },
      { name: "enabled", type: "checkbox", value: "on", checked: true },
    ])).toEqual({ tool_names: ["file.read"], enabled: true });
  });
});

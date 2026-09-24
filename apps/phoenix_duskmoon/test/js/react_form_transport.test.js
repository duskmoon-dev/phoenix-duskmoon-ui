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
});

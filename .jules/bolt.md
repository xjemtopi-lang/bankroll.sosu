# Bolt's Performance Journal

## 2026-08-31 - Guarding Instance Property Assignments in Luau Render Loops
**Learning:** Assigning Instance properties in Roblox Luau (e.g., `hum.AutoRotate = false`) every frame inside `RenderStepped` or `Stepped` loops incurs a unnecessary bridge crossing overhead between Luau and the underlying Roblox C++ engine core. Checking if the property is already set before assigning eliminates this bridge overhead.
**Action:** Always guard per-frame property assignments with an equality check (e.g. `if hum.AutoRotate ~= false then hum.AutoRotate = false end`).

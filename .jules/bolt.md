## 2026-08-30 - Guarding Roblox Instance Property Assignments in Hot Loops
**Learning:** Assigning Instance properties across the Luau-to-C++ engine bridge every frame (e.g. `hum.WalkSpeed`, `hum.AutoRotate`, `part.CanCollide` in `RenderStepped`/`Stepped`) incurs unnecessary C++ interop overhead even when the assigned value does not change.
**Action:** Always check if property values differ before writing to them in per-frame loops (`if hum.WalkSpeed ~= RageSettings.StrafeSpeed then hum.WalkSpeed = RageSettings.StrafeSpeed end`).

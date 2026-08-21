## 2026-08-18 - Cache Roblox UI DOM references in high-frequency render loops

**Learning:** Calling `FindFirstChild` repeatedly inside `RunService.RenderStepped` for every player introduces unnecessary string hashing and DOM hierarchy searching on every rendered frame (~60-144 FPS).
**Action:** Always pre-cache UI element references (e.g. HealthBar, WeaponLabel, Box) in a table/hash map when creating player ESP instances and look them up with O(1) table indexing during frame loops.

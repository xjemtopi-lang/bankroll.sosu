## 2026-08-18 - Roblox Luau RenderStepped Instance Lookups Anti-Pattern
**Learning:** Using `FindFirstChild` with string concatenation (`"Box_" .. plr.Name`) inside high-frequency `RenderStepped` loops (60-120+ FPS) creates high garbage collection pressure from string allocations and crosses the Luau/C++ boundary multiple times per player frame.
**Action:** Cache UI instance references directly in a Luau table keyed by Player object (`ESPMap[plr] = {Box, Health, Weapon}`) upon instance creation, and clean up on `PlayerRemoving`.

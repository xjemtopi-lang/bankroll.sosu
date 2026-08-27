# Bolt's Journal - Critical Learnings

## 2026-08-27 - Caching Roblox UI instances in RenderStepped loop
**Learning:** In Roblox Lua scripts running on mobile executors, string concatenation (`"Box_" .. plr.Name`) and `FindFirstChild` calls inside high-frequency `RenderStepped` loops (60+ FPS) create GC pressure and CPU overhead. Caching UI instances (`Box`, `HealthBar`, `WeaponLabel`) in a key-value dictionary (`ESPCache[player]`) removes O(N) DOM child searches every frame.
**Action:** Always store child component references in a Lua table during creation (`CreatePlayerESP`) and clean up on `PlayerRemoving`.

## 2025-08-17 - Avoid DOM & Instance Lookups in High-Frequency RenderStepped Loops

**Learning:** In Luau/Roblox scripts running at 60+ FPS inside `RunService.RenderStepped`, performing repeated Instance lookups (`parent:FindFirstChild("Box_" .. plr.Name)`) and object allocations (`UDim2.new(...)`, `Vector2.new(...)`) inside player iteration loops causes measurable GC pressure and frame frame time spikes.
**Action:** Store UI component references in a local table (`espCache[plr]`) populated on `PlayerAdded` and cleaned up on `PlayerRemoving`. Hoist invariant calculations (such as viewport centers) outside of loops, and mutate UI element properties only when states/values actually change.

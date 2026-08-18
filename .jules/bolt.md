## 2026-08-18 - Localizing globals in Luau per-frame loops
**Learning:** In Luau/Roblox Lua per-frame signals like `RunService.RenderStepped`, looking up global table functions (`math.rad`, `math.atan2`, `CFrame.Angles`, `CFrame.new`) repeatedly incurs hash table lookup overhead every frame. Localizing these functions at top-level script scope significantly reduces variable resolution overhead in hot execution loops.
**Action:** Always localize frequently invoked math and CFrame constructor functions before registering per-frame RenderStepped or Stepped callbacks.

# Bolt's Journal - Critical Learnings

## 2026-08-23 - Table Allocations in RenderStepped/ESP Loops
**Learning:** In Roblox Luau scripts running on mobile executors, creating temporary nested tables (like `corners_pos = { {Vector2, Vector2}, ... }`) and calling `c:GetChildren()` inside high-frequency `RenderStepped` or throttle loops creates thousands of transient table allocations per second, leading to Garbage Collection (GC) stutters on mobile devices.
**Action:** Direct property assignment and C++ engine methods like `FindFirstChildOfClass("Tool")` should be used instead of transient table creation in loop bodies.

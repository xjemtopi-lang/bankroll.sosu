## 2026-08-29 - [Roblox Luau ESP Element Lookup Caching]
**Learning:** Calling `FindFirstChild` and string concatenation inside per-frame loops (`RenderStepped` / `Heartbeat`) creates severe CPU overhead on mobile executors (Delta, Codex, etc.). Caching UI element references in a player-mapped table (`EspCache`) eliminates O(N*3) DOM lookups per frame.
**Action:** Always store UI element references in a local table upon instantiation when updating visual elements every frame, and handle cleanup in `Players.PlayerRemoving`.

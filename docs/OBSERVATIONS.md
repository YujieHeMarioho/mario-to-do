# Reference observations

Reference: installed Microsoft To Do 2.177, Apple Silicon macOS application.

Observed through the application UI: sidebar with My Day, Important, Planned, Assigned to me, Flagged email, Tasks, custom lists, new list and new group; account header and task search. My Day uses a full background, date under title, suggestions and list options at top right, and task creation anchored at the bottom.

REA open_binary authenticated the installed Mach-O target. inspect_macho could not run because the installed Xcode toolchain lacks dyld_info. No decompilation or behavioral equivalence is claimed. UI inspection is the reference for layout; implementation choices below are independent.

No personal task contents or identity have been copied into the new application or repository.

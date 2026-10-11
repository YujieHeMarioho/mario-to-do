# Mario To Do

An independent, local-first macOS task manager inspired by the layout and workflows of Microsoft To Do. Original implementation, branding, and artwork; no Microsoft binaries, assets, account tokens, or personal task data are included.

Build with `bash build.sh` on an Apple Silicon Mac with Xcode Command Line Tools. Open `build/Mario To Do.app`.

## Scope

My Day, Important, Planned, All Tasks, local assignment and email-reference views; task editing, steps, notes, due dates, recurrence, reminders while running, custom lists and groups, themes, search, sorting, suggestions, completed tasks, restore from trash, JSON import/export, attachments, and printing.

Microsoft account synchronization, Outlook integration, and online collaboration are not implemented. Local assignments and email references do not communicate with Microsoft services. This is not a claim of complete equivalence with Microsoft To Do.

Application data lives in ~/Library/Application Support/Mario To Do, outside this repository. Reminders are checked while the app is running. A timestamped local backup is created before every import. Backup export includes task metadata; attached files must be backed up separately.

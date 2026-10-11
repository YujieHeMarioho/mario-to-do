# Validation

- Compiled native Apple Silicon macOS app with Swift 5.10 and the installed system SDK; ad-hoc code signature verified.
- Opened the actual packaged app and inspected its screenshot and accessibility tree.
- Created a task through UI, edited its title to Chinese text, added a Chinese step, and toggled importance. Verified atomic JSON persistence on disk.
- Automated isolated-state checks: month-end recurrence clips correctly to February; completing a recurring task creates the next occurrence; steps, Unicode note search, delete/restore, undo, smart-list filtering, notification deduplication, invalid backup IDs, and HTML escaping.
- Reminders are checked only while running; operating-system notification permission and presentation settings affect notification banners. An in-app reminder is also displayed.
- Cloud sync, real assignment/sharing, Microsoft sign-in and Outlook integration remain unsupported. Visual design is independently implemented from observed UI and is not pixel-equivalent.
- Reopened the final application from its installed SuperMario location and verified the Chinese task, step, and importance survived restart. Completed and reopened a task through UI; created a Chinese custom list through the native prompt.
- Installed a desktop application symlink pointing to the SuperMario application bundle; requires the external volume to stay mounted.


# Changelog

## v1.1.0 - Notifications

### Now requires [TackleBox](https://thunderstore.io/c/webfishing/p/PuppyGirl/TackleBox/) mod as dependency

- **New feature**: Window notifications on messages/mentions
- **New feature**: Sounds on messages/mentions

## v1.0.0 - The Twitter Update

- ~130-character message length restriction removed!

## v0.2.0 - More LucysTools compatibility...

- **_Now requires Socks as a dependency_**
- If you have configured BetterLocalChat settings (e.g., with Tacklebox) they will now be applied to the BLC LucysLib plugin, too
  - I.e., Infinite `LOCAL` chat range should be working
  - This **_requires you have Tacklebox installed_** as it uses their API to read your config

## v0.1.1

- Fix small bug that prevented BBCode tags (rich text) from showing in `LOCAL` messages when using LucysTools

## v0.1.0

- New feature! Ignored server commands
  - Using server commands like `!kick player` will now be sent silently without emitting speech or a chat bubble.

## v0.0.3

- Minor rework to handling of global messages
  - If you had issues with global-local messages, this should resolve those
- Bundled new LucyLib plugin for mod compatibility (Let me know if you see issues)

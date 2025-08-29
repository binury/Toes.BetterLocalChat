# Better Local Chat

- Wax poetically about your deep thoughts with ~300% longer messages (164 ⇒ 480 char limit)
- No more ugly message prefixes!
- `LOCAL` messages show in Global too!
- `/l` command to chat from `GLOBAL` without changing tabs!
- Use server commands (e.g., `!kick`, `!spawn meatball`) without emitting speech or creating a chat bubble

While chatting in `GLOBAL` you can now prefix any message with a new `/l` command in order to send it as a `LOCAL` message.
(Although I don't imagine it will happen often you _can_ also combine `/l /me emotes` and chain these commands to emote in `LOCAL`. `/l` works the very same way that your `/me` emotes do.)

Additionally, `LOCAL` messages are _also_ shown under the `GLOBAL` tab with a clean and simple message prefix
for distinction. This way, you don't have to choose missing out on `GLOBAL` messages while having a `LOCAL` conversation. Now you can have both.

The glitchy-looking text cramping up everyone's messages in the `LOCAL` tab is patched and removed, too.

Using server commands like `!kick player` will now be sent silently without emitting speech or a chat bubble.
This is enabled by default \_but can be disabled in the mod configuration\_\_.

## Feedback

Please feel free to reach out to us with feedback or to share your ideas
[here](https://github.com/binury/Toes.BetterLocalChat/issues)!

## Support the mod maker

<a href='https://ko-fi.com/A0A3YDMVY' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi4.png?v=6' border='0' alt='Buy Toes a Coffee at ko-fi.com' /></a>

## Roadmap

(Coming soon)

## Changelog

### v1.0.0 - The Twitter Update

- ~130-character message length restriction removed!

### v0.2.0 - More LucysTools compatibility...

- **_Now requires Socks as a dependency_**
- If you have configured BetterLocalChat settings (e.g., with Tacklebox) they will now be applied to the BLC LucysLib plugin, too
  - I.e., Infinite `LOCAL` chat range should be working
  - This **_requires you have Tacklebox installed_** as it uses their API to read your config

### v0.1.1

- Fix small bug that prevented BBCode tags (rich text) from showing in `LOCAL` messages when using LucysTools

### v0.1.0

- New feature! Ignored server commands
  - Using server commands like `!kick player` will now be sent silently without emitting speech or a chat bubble.

### v0.0.3

- Minor rework to handling of global messages
  - If you had issues with global-local messages, this should resolve those
- Bundled new LucyLib plugin for mod compatibility (Let me know if you see issues)

# Better Local Chat

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
This is enabled by default _but can be disabled in the mod configuration__.

## Feedback

Please feel free to reach out to us with feedback or to share your ideas
[here](https://github.com/binury/Toes.BetterLocalChat/issues)!

## Support the mod maker

<a href='https://ko-fi.com/A0A3YDMVY' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi4.png?v=6' border='0' alt='Buy Toes a Coffee at ko-fi.com' /></a>

## Roadmap

(Coming soon)

## Changelog

### v0.1.0
- New feature! Ignored server commands
	- Using server commands like `!kick player` will now be sent silently without emitting speech or a chat bubble.

### v0.0.3
- Minor rework to handling of global messages
	- If you had issues with global-local messages, this should resolve those
- Bundled new LucyLib plugin for mod compatibility (Let me know if you see issues)


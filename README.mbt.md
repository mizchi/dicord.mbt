# discord

MoonBit implementation of the `mizchi/discord-cf` REST/API layer.

## Features

- Discord API v10 REST client
- API modules: `channels`, `users`, `guilds`, `webhooks`, `interactions`, `voice`
- Configurable auth mode (`Bot token`, explicit token, no auth)
- JS target `fetch` backend
- `mizchi/cloudflare` integration (`mizchi/discord/cfw`)

## Quick Start

```mbt check
///|
test {
  let rest = new_rest_client(token="DISCORD_BOT_TOKEN")
  let api = new_api(rest)

  // Prepare and inspect request details before calling API
  let prepared = rest.prepare_request(
    request_method_get(),
    route_channel_messages("1234567890"),
    request_options(query=[("limit", "10")]),
  )

  inspect(
    prepared.url,
    content="https://discord.com/api/v10/channels/1234567890/messages?limit=10",
  )

  // API modules are available from new_api(rest)
  inspect(api.users.rest.options.timeout_ms, content="15000")
}
```

## Commands

```bash
just check
just test
just info
```

## Cloudflare Worker Integration

`src/cfw` exports `get_discord_handler`.

```bash
moon build src/cfw --target js
npx wrangler dev --config fixtures/wrangler.jsonc
```

Handler routes:

- `GET /health`
- `GET /discord/send?channel_id=...&content=...`
  - if `channel_id` is omitted, `DISCORD_CHANNEL_ID` is used

Required environment variables:

- `DISCORD_TOKEN` (required)
- `DISCORD_CHANNEL_ID` (optional)

`fixtures/cf-worker.js` loads `target/js/release/build/cfw/cfw.js`
and wires `get_discord_handler()` to Worker `fetch`.

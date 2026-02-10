# discord-cf-mbt

MoonBit implementation of the `mizchi/discord-cf` REST/API layer.

## Features

- Discord API v10 REST client
- API modules: `channels`, `users`, `guilds`, `webhooks`, `interactions`, `voice`
- Configurable auth mode (`Bot token`, explicit token, no auth)
- JS target `fetch` backend
- `mizchi/cloudflare` 連携 (`mizchi/discord-cf-mbt/cfw`)

## Example

```moonbit
let rest = new_rest_client(token="DISCORD_BOT_TOKEN")
let api = new_api(rest)

let prepared = rest.prepare_request(
  request_method_get(),
  route_channel_messages("1234567890"),
  request_options(query=[("limit", "10")]),
)

inspect(prepared.url)
// https://discord.com/api/v10/channels/1234567890/messages?limit=10
```

## Cloudflare Worker Integration

`src/cfw` パッケージで `get_discord_handler` を export します。

```bash
moon build src/cfw --target js
npx wrangler dev --config fixtures/wrangler.jsonc
```

ハンドラのルート:

- `GET /health`
- `GET /discord/send?channel_id=...&content=...`
  - `channel_id` 省略時は `DISCORD_CHANNEL_ID` を使用

必要な環境変数:

- `DISCORD_TOKEN` (required)
- `DISCORD_CHANNEL_ID` (optional)

`fixtures/cf-worker.js` は `target/js/release/build/cfw/cfw.js` を読み込んで
`get_discord_handler()` を Worker の `fetch` に接続します。

## Development

```bash
just check
just test
just info
```

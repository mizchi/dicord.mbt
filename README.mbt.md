# discord-cf-mbt

MoonBit で書かれた Discord REST API クライアントです。  
`mizchi/discord-cf` の REST/API 層をベースに移植しています。

## Features

- Discord API v10 向け REST クライアント
- `channels/users/guilds/webhooks/interactions/voice` API モジュール
- `AuthMode` による認証切り替え（Bot token / 明示 token / auth なし）
- JS target 向け `fetch` 実装
- `mizchi/cloudflare` 連携 (`mizchi/discord-cf-mbt/cfw`)

## Quick Start

```mbt check
///|
test {
  let rest = new_rest_client(token="DISCORD_BOT_TOKEN")
  let api = new_api(rest)

  // API 呼び出し前に request 内容を組み立て確認できる
  let prepared = rest.prepare_request(
    request_method_get(),
    route_channel_messages("1234567890"),
    request_options(query=[("limit", "10")]),
  )

  inspect(
    prepared.url,
    content="https://discord.com/api/v10/channels/1234567890/messages?limit=10",
  )

  // モジュール構成
  inspect(api.users.rest.options.timeout_ms, content="15000")
}
```

## Commands

```bash
just check
just test
just info
```

## Cloudflare Worker 連携

`src/cfw` パッケージで `get_discord_handler` を export します。

```bash
moon build src/cfw --target js
npx wrangler dev --config fixtures/wrangler.toml
```

ハンドラが持つルート:

- `GET /health`
- `GET /discord/send?channel_id=...&content=...`
  - `channel_id` が無い場合は `DISCORD_CHANNEL_ID` を利用

必要な環境変数:

- `DISCORD_TOKEN` (必須)
- `DISCORD_CHANNEL_ID` (任意)

`fixtures/cf-worker.js` が `target/js/release/build/cfw/cfw.js` の
`get_discord_handler()` を Worker の `fetch` に接続します。

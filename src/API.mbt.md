# API Documentation

`discord-cf` を MoonBit に移植した最小 API です。

## REST Client

```mbt check
///|
test {
  let rest = new_rest_client(token="TOKEN")
  let prepared = rest.prepare_request(
    request_method_get(),
    route_channel_messages("123"),
    request_options(query=[("limit", "10")]),
  )
  inspect(
    prepared.url,
    content="https://discord.com/api/v10/channels/123/messages?limit=10",
  )
}
```

## API Modules

```mbt check
///|
test {
  let api = new_api(new_rest_client())
  inspect(route_user("@me"), content="/users/@me")
  inspect(route_guild_role("1", "2"), content="/guilds/1/roles/2")
  inspect(api.voice.rest.options.timeout_ms, content="15000")
}
```

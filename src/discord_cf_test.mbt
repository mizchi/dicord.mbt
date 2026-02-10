///|
pub(all) struct MockFetchCall {
  meth : String
  url : String
  headers_json : String
  body : String?
}

///|
extern "js" fn install_mock_fetch(
  status : Int,
  content_type : String?,
  body : String,
) -> Unit =
  #| (status, contentType, body) => {
  #|   if (globalThis.__discord_cf_original_fetch === undefined) {
  #|     globalThis.__discord_cf_original_fetch = globalThis.fetch;
  #|   }
  #|   globalThis.__discord_cf_calls = [];
  #|   globalThis.fetch = async (url, init = {}) => {
  #|     const headers = new Headers(init.headers ?? {});
  #|     const headerObject = {};
  #|     headers.forEach((value, key) => {
  #|       headerObject[key] = value;
  #|     });
  #|     globalThis.__discord_cf_calls.push({
  #|       meth: init.method ?? "GET",
  #|       url: String(url),
  #|       headers_json: JSON.stringify(headerObject),
  #|       body: init.body == null ? undefined : String(init.body),
  #|     });
  #|     return {
  #|       ok: status >= 200 && status < 300,
  #|       status,
  #|       headers: {
  #|         get(name) {
  #|           if (name.toLowerCase() === "content-type") {
  #|             return contentType ?? null;
  #|           }
  #|           return null;
  #|         },
  #|       },
  #|       text: async () => body,
  #|     };
  #|   };
  #| }

///|
extern "js" fn install_rejected_mock_fetch(message : String) -> Unit =
  #| (message) => {
  #|   if (globalThis.__discord_cf_original_fetch === undefined) {
  #|     globalThis.__discord_cf_original_fetch = globalThis.fetch;
  #|   }
  #|   globalThis.__discord_cf_calls = [];
  #|   globalThis.fetch = async (url, init = {}) => {
  #|     const headers = new Headers(init.headers ?? {});
  #|     const headerObject = {};
  #|     headers.forEach((value, key) => {
  #|       headerObject[key] = value;
  #|     });
  #|     globalThis.__discord_cf_calls.push({
  #|       meth: init.method ?? "GET",
  #|       url: String(url),
  #|       headers_json: JSON.stringify(headerObject),
  #|       body: init.body == null ? undefined : String(init.body),
  #|     });
  #|     throw new Error(message);
  #|   };
  #| }

///|
extern "js" fn restore_fetch() -> Unit =
  #| () => {
  #|   if (globalThis.__discord_cf_original_fetch !== undefined) {
  #|     globalThis.fetch = globalThis.__discord_cf_original_fetch;
  #|   }
  #|   globalThis.__discord_cf_calls = [];
  #| }

///|
extern "js" fn get_mock_fetch_calls() -> Array[MockFetchCall] =
  #| () => globalThis.__discord_cf_calls ?? []

///|
fn json_object(entries : Array[(String, Json)]) -> Json {
  Json::object(Map::from_array(entries))
}

///|
fn parse_headers(call : MockFetchCall) -> Map[String, String] {
  let parsed = try? @json.parse(call.headers_json)
  match parsed {
    Ok(Object(obj)) => {
      let headers = Map::new()
      for key, value in obj {
        if value is String(text) {
          headers.set(key, text)
        }
      }
      headers
    }
    _ => {}
  }
}

///|
fn get_header(call : MockFetchCall, key : String) -> String? {
  parse_headers(call).get(key)
}

///|
fn parse_body_content(call : MockFetchCall) -> String? {
  match call.body {
    Some(body) => {
      let parsed = try? @json.parse(body)
      match parsed {
        Ok(Object(obj)) =>
          match obj.get("content") {
            Some(String(value)) => Some(value)
            _ => None
          }
        _ => None
      }
    }
    None => None
  }
}

///|
test "route helpers" {
  inspect(route_channel_messages("123"), content="/channels/123/messages")
  inspect(
    route_channel_message("123", "999"),
    content="/channels/123/messages/999",
  )
  inspect(
    route_interaction_callback("abc", "token"),
    content="/interactions/abc/token/callback",
  )
  inspect(
    route_webhook_message("1", "tok", "@original"),
    content="/webhooks/1/tok/messages/@original",
  )
  inspect(route_guild_role("g1", "r1"), content="/guilds/g1/roles/r1")
}

///|
test "query encoder" {
  let empty_query : Array[(String, String)] = []
  inspect(
    encode_query([("limit", "10"), ("after", "123")]),
    content="limit=10&after=123",
  )
  inspect(encode_query(empty_query), content="")
}

///|
async test "rest and api flows" {
  {
    install_mock_fetch(200, Some("application/json"), "{\"ok\":true}")
    defer restore_fetch()
    let rest = RestClient::new().with_token("test-token")
    let result = rest.get(
      "/test",
      options=request_options(query=[("limit", "10"), ("after", "123")]),
    )
    inspect(result is Ok(_), content="true")
    let calls = get_mock_fetch_calls()
    inspect(calls.length(), content="1")
    inspect(calls[0].meth, content="GET")
    inspect(
      calls[0].url,
      content="https://discord.com/api/v10/test?limit=10&after=123",
    )
    inspect(
      get_header(calls[0], "authorization"),
      content="Some(\"Bot test-token\")",
    )
    inspect(
      get_header(calls[0], "user-agent"),
      content="Some(\"CloudflareDiscordJS/0.1.0\")",
    )
  }
  {
    install_mock_fetch(200, Some("application/json"), "{}")
    defer restore_fetch()
    let rest = RestClient::new().with_token("test-token")
    ignore(
      rest.post(
        "/messages",
        options=request_options(
          body=json_object([("content", Json::string("hello"))]),
        ),
      ),
    )
    let call = get_mock_fetch_calls()[0]
    inspect(call.meth, content="POST")
    inspect(
      get_header(call, "content-type"),
      content="Some(\"application/json\")",
    )
    inspect(parse_body_content(call), content="Some(\"hello\")")
  }
  {
    install_mock_fetch(
      404,
      Some("application/json"),
      "{\"message\":\"Not Found\"}",
    )
    defer restore_fetch()
    let rest = RestClient::new().with_token("test-token")
    let result = rest.get("/missing")
    let ok = match result {
      Err(ApiError(404, "Not Found")) => true
      _ => false
    }
    inspect(ok, content="true")
  }
  {
    install_rejected_mock_fetch("Network error")
    defer restore_fetch()
    let rest = RestClient::new().with_token("test-token")
    let result = rest.get("/test")
    let ok = match result {
      Err(Network(message)) => message.contains("Network error")
      _ => false
    }
    inspect(ok, content="true")
  }
  install_mock_fetch(200, Some("application/json"), "{}")
  defer restore_fetch()
  let rest = RestClient::new().with_token("test-token")
  let api = API::new(rest)
  ignore(
    api.channels.create_message(
      "123",
      json_object([("content", Json::string("hello"))]),
    ),
  )
  ignore(api.users.get_current())
  ignore(
    api.guilds.create_role(
      "guild-1",
      json_object([("name", Json::string("role"))]),
    ),
  )
  ignore(
    api.webhooks.execute(
      "webhook-id",
      "webhook-token",
      json_object([("content", Json::string("payload"))]),
      wait=true,
      thread_id="thread-1",
    ),
  )
  let calls = get_mock_fetch_calls()
  inspect(calls.length(), content="4")
  inspect(
    calls[0].url,
    content="https://discord.com/api/v10/channels/123/messages",
  )
  inspect(calls[1].url, content="https://discord.com/api/v10/users/@me")
  inspect(
    calls[2].url,
    content="https://discord.com/api/v10/guilds/guild-1/roles",
  )
  inspect(
    calls[3].url,
    content="https://discord.com/api/v10/webhooks/webhook-id/webhook-token?wait=true&thread_id=thread-1",
  )
  inspect(get_header(calls[3], "authorization"), content="None")
}

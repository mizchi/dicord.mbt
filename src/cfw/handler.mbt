///|
extern "js" fn json_response(body : String, status : Int) -> @http.Response =
  #| (body, status) =>
  #|   new Response(body, {
  #|     status,
  #|     headers: { "Content-Type": "application/json" },
  #|   })

///|
pub fn resolve_channel_id(
  query_channel_id : String?,
  env_channel_id : String?,
) -> String? {
  match query_channel_id {
    Some(channel_id) => Some(channel_id)
    None => env_channel_id
  }
}

///|
pub fn resolve_content(query_content : String?) -> String {
  match query_content {
    Some(content) => content
    None => "hello from discord-cf-mbt"
  }
}

///|
pub fn build_message_body(content : String) -> Json {
  Json::object({ "content": Json::string(content) })
}

///|
fn response_error(message : String, status : Int) -> @http.Response {
  json_response(
    Json::object({ "ok": Json::boolean(false), "error": Json::string(message) }).stringify(),
    status,
  )
}

///|
fn response_json(body : Json, status : Int) -> @http.Response {
  json_response(body.stringify(), status)
}

///|
fn get_env_string(env : @cloudflare.CloudflareEnv, key : String) -> String? {
  let value = env.as_any()._get(key)
  if @core.typeof_(value) == "string" {
    Some(@core.identity(value))
  } else {
    None
  }
}

///|
pub fn get_discord_handler() -> @cloudflare.CloudflareFetchHandler {
  let async_handler = async fn(
    req : @cloudflare.CloudflareRequest,
    env : @cloudflare.CloudflareEnv,
    _ctx : @cloudflare.CloudflareContext,
  ) -> @http.Response {
    let url = @url.URL::new(req.url) catch {
      _ => return response_error("invalid request url", 400)
    }
    let path = url.pathname
    if path == "/health" {
      return response_json(
        Json::object({
          "ok": Json::boolean(true),
          "service": Json::string("discord-cf-mbt"),
        }),
        200,
      )
    }
    if path != "/discord/send" {
      return response_error("route not found", 404)
    }
    let token = get_env_string(env, "DISCORD_TOKEN")
    let channel_id = resolve_channel_id(
      url.searchParams().get("channel_id"),
      get_env_string(env, "DISCORD_CHANNEL_ID"),
    )
    let content = resolve_content(url.searchParams().get("content"))
    if token is None {
      return response_error("missing DISCORD_TOKEN", 500)
    }
    if channel_id is None {
      return response_error("missing channel_id or DISCORD_CHANNEL_ID", 400)
    }
    let rest = @discord.new_rest_client(token=token.unwrap())
    let api = @discord.new_api(rest)
    let result = api.channels.create_message(
      channel_id.unwrap(),
      build_message_body(content),
    )
    match result {
      Ok(message) =>
        response_json(
          Json::object({ "ok": Json::boolean(true), "message": message }),
          200,
        )
      Err(err) => response_error(err.to_string(), 500)
    }
  }
  @core.promisify3(async_handler)
}

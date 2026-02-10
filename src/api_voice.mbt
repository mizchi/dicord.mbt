///|
pub struct VoiceAPI {
  rest : RestClient
}

///|
pub fn VoiceAPI::new(rest : RestClient) -> VoiceAPI {
  { rest, }
}

///|
fn merge_voice_state_body(channel_id : String, options : Json?) -> Json {
  let body = { "channel_id": Json::string(channel_id) }
  if options is Some(Object(obj)) {
    for key, value in obj {
      body.set(key, value)
    }
  }
  Json::object(body)
}

///|
pub async fn VoiceAPI::list_voice_regions(
  self : VoiceAPI,
) -> Result[Json, RestError] {
  self.rest.get(route_voice_regions())
}

///|
pub async fn VoiceAPI::get_voice_state(
  self : VoiceAPI,
  guild_id : String,
  user_id : String,
) -> Result[Json, RestError] {
  self.rest.get(route_guild_voice_state(guild_id, user_id))
}

///|
pub async fn VoiceAPI::modify_current_user_voice_state(
  self : VoiceAPI,
  guild_id : String,
  channel_id : String,
  options? : Json,
) -> Result[Json, RestError] {
  self.rest.patch(
    route_guild_voice_state(guild_id, "@me"),
    options=request_options(body=merge_voice_state_body(channel_id, options)),
  )
}

///|
pub async fn VoiceAPI::modify_user_voice_state(
  self : VoiceAPI,
  guild_id : String,
  user_id : String,
  channel_id : String,
  options? : Json,
) -> Result[Json, RestError] {
  self.rest.patch(
    route_guild_voice_state(guild_id, user_id),
    options=request_options(body=merge_voice_state_body(channel_id, options)),
  )
}

///|
pub async fn VoiceAPI::get_guild_voice_regions(
  self : VoiceAPI,
  guild_id : String,
) -> Result[Json, RestError] {
  self.rest.get(route_guild_regions(guild_id))
}

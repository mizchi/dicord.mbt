///|
pub struct ChannelsAPI {
  rest : RestClient
}

///|
pub fn ChannelsAPI::new(rest : RestClient) -> ChannelsAPI {
  { rest, }
}

///|
pub async fn ChannelsAPI::create_message(
  self : ChannelsAPI,
  channel_id : String,
  body : Json,
  auth_mode? : AuthMode = UseClientToken,
) -> Result[Json, RestError] {
  self.rest.post(
    route_channel_messages(channel_id),
    options=request_options(auth_mode~, body~),
  )
}

///|
pub async fn ChannelsAPI::edit_message(
  self : ChannelsAPI,
  channel_id : String,
  message_id : String,
  body : Json,
  auth_mode? : AuthMode = UseClientToken,
) -> Result[Json, RestError] {
  self.rest.patch(
    route_channel_message(channel_id, message_id),
    options=request_options(auth_mode~, body~),
  )
}

///|
pub async fn ChannelsAPI::delete_message(
  self : ChannelsAPI,
  channel_id : String,
  message_id : String,
) -> Result[Json, RestError] {
  self.rest.delete(route_channel_message(channel_id, message_id))
}

///|
pub async fn ChannelsAPI::get_message(
  self : ChannelsAPI,
  channel_id : String,
  message_id : String,
) -> Result[Json, RestError] {
  self.rest.get(route_channel_message(channel_id, message_id))
}

///|
pub async fn ChannelsAPI::get_messages(
  self : ChannelsAPI,
  channel_id : String,
  query? : Array[(String, String)] = [],
) -> Result[Json, RestError] {
  self.rest.get(
    route_channel_messages(channel_id),
    options=request_options(query~),
  )
}

///|
pub async fn ChannelsAPI::get(
  self : ChannelsAPI,
  channel_id : String,
) -> Result[Json, RestError] {
  self.rest.get(route_channel(channel_id))
}

///|
pub async fn ChannelsAPI::create_reaction(
  self : ChannelsAPI,
  channel_id : String,
  message_id : String,
  emoji : String,
) -> Result[Json, RestError] {
  self.rest.put(
    route_channel_message_own_reaction(channel_id, message_id, emoji),
  )
}

///|
pub async fn ChannelsAPI::delete_own_reaction(
  self : ChannelsAPI,
  channel_id : String,
  message_id : String,
  emoji : String,
) -> Result[Json, RestError] {
  self.rest.delete(
    route_channel_message_own_reaction(channel_id, message_id, emoji),
  )
}

///|
pub async fn ChannelsAPI::trigger_typing_indicator(
  self : ChannelsAPI,
  channel_id : String,
) -> Result[Json, RestError] {
  self.rest.post(route_channel_typing(channel_id))
}

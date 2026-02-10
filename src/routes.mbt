///|
pub fn route_channel_messages(channel_id : String) -> String {
  "/channels/\{channel_id}/messages"
}

///|
pub fn route_channel_message(
  channel_id : String,
  message_id : String,
) -> String {
  "/channels/\{channel_id}/messages/\{message_id}"
}

///|
pub fn route_channel(channel_id : String) -> String {
  "/channels/\{channel_id}"
}

///|
pub fn route_channel_message_own_reaction(
  channel_id : String,
  message_id : String,
  emoji : String,
) -> String {
  "/channels/\{channel_id}/messages/\{message_id}/reactions/\{emoji}/@me"
}

///|
pub fn route_channel_typing(channel_id : String) -> String {
  "/channels/\{channel_id}/typing"
}

///|
pub fn route_interaction_callback(
  interaction_id : String,
  interaction_token : String,
) -> String {
  "/interactions/\{interaction_id}/\{interaction_token}/callback"
}

///|
pub fn route_webhook(id : String, token : String) -> String {
  "/webhooks/\{id}/\{token}"
}

///|
pub fn route_webhook_message(
  id : String,
  token : String,
  message_id : String,
) -> String {
  "/webhooks/\{id}/\{token}/messages/\{message_id}"
}

///|
pub fn route_user(user_id : String) -> String {
  "/users/\{user_id}"
}

///|
pub fn route_user_guilds() -> String {
  "/users/@me/guilds"
}

///|
pub fn route_user_channels() -> String {
  "/users/@me/channels"
}

///|
pub fn route_guild(guild_id : String) -> String {
  "/guilds/\{guild_id}"
}

///|
pub fn route_guild_channels(guild_id : String) -> String {
  "/guilds/\{guild_id}/channels"
}

///|
pub fn route_guild_member(guild_id : String, user_id : String) -> String {
  "/guilds/\{guild_id}/members/\{user_id}"
}

///|
pub fn route_guild_members(guild_id : String) -> String {
  "/guilds/\{guild_id}/members"
}

///|
pub fn route_guild_roles(guild_id : String) -> String {
  "/guilds/\{guild_id}/roles"
}

///|
pub fn route_guild_role(guild_id : String, role_id : String) -> String {
  "/guilds/\{guild_id}/roles/\{role_id}"
}

///|
pub fn route_guild_voice_state(guild_id : String, user_id : String) -> String {
  "/guilds/\{guild_id}/voice-states/\{user_id}"
}

///|
pub fn route_voice_regions() -> String {
  "/voice/regions"
}

///|
pub fn route_guild_regions(guild_id : String) -> String {
  "/guilds/\{guild_id}/regions"
}

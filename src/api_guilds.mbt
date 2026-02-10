///|
pub struct GuildsAPI {
  rest : RestClient
}

///|
pub fn GuildsAPI::new(rest : RestClient) -> GuildsAPI {
  { rest, }
}

///|
pub async fn GuildsAPI::get(
  self : GuildsAPI,
  guild_id : String,
) -> Result[Json, RestError] {
  self.rest.get(route_guild(guild_id))
}

///|
pub async fn GuildsAPI::edit(
  self : GuildsAPI,
  guild_id : String,
  body : Json,
) -> Result[Json, RestError] {
  self.rest.patch(route_guild(guild_id), options=request_options(body~))
}

///|
pub async fn GuildsAPI::delete(
  self : GuildsAPI,
  guild_id : String,
) -> Result[Json, RestError] {
  self.rest.delete(route_guild(guild_id))
}

///|
pub async fn GuildsAPI::get_channels(
  self : GuildsAPI,
  guild_id : String,
) -> Result[Json, RestError] {
  self.rest.get(route_guild_channels(guild_id))
}

///|
pub async fn GuildsAPI::create_channel(
  self : GuildsAPI,
  guild_id : String,
  body : Json,
) -> Result[Json, RestError] {
  self.rest.post(route_guild_channels(guild_id), options=request_options(body~))
}

///|
pub async fn GuildsAPI::get_member(
  self : GuildsAPI,
  guild_id : String,
  user_id : String,
) -> Result[Json, RestError] {
  self.rest.get(route_guild_member(guild_id, user_id))
}

///|
pub async fn GuildsAPI::get_members(
  self : GuildsAPI,
  guild_id : String,
  query? : Array[(String, String)] = [],
) -> Result[Json, RestError] {
  self.rest.get(route_guild_members(guild_id), options=request_options(query~))
}

///|
pub async fn GuildsAPI::get_roles(
  self : GuildsAPI,
  guild_id : String,
) -> Result[Json, RestError] {
  self.rest.get(route_guild_roles(guild_id))
}

///|
pub async fn GuildsAPI::create_role(
  self : GuildsAPI,
  guild_id : String,
  body : Json,
) -> Result[Json, RestError] {
  self.rest.post(route_guild_roles(guild_id), options=request_options(body~))
}

///|
pub async fn GuildsAPI::edit_role(
  self : GuildsAPI,
  guild_id : String,
  role_id : String,
  body : Json,
) -> Result[Json, RestError] {
  self.rest.patch(
    route_guild_role(guild_id, role_id),
    options=request_options(body~),
  )
}

///|
pub async fn GuildsAPI::delete_role(
  self : GuildsAPI,
  guild_id : String,
  role_id : String,
) -> Result[Json, RestError] {
  self.rest.delete(route_guild_role(guild_id, role_id))
}

///|
pub struct UsersAPI {
  rest : RestClient
}

///|
pub fn UsersAPI::new(rest : RestClient) -> UsersAPI {
  { rest, }
}

///|
pub async fn UsersAPI::get(
  self : UsersAPI,
  user_id : String,
) -> Result[Json, RestError] {
  self.rest.get(route_user(user_id))
}

///|
pub async fn UsersAPI::get_current(self : UsersAPI) -> Result[Json, RestError] {
  self.rest.get(route_user("@me"))
}

///|
pub async fn UsersAPI::edit(
  self : UsersAPI,
  body : Json,
) -> Result[Json, RestError] {
  self.rest.patch(route_user("@me"), options=request_options(body~))
}

///|
pub async fn UsersAPI::get_guilds(
  self : UsersAPI,
  query? : Array[(String, String)] = [],
) -> Result[Json, RestError] {
  self.rest.get(route_user_guilds(), options=request_options(query~))
}

///|
pub async fn UsersAPI::create_dm(
  self : UsersAPI,
  body : Json,
) -> Result[Json, RestError] {
  self.rest.post(route_user_channels(), options=request_options(body~))
}

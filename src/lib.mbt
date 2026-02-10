///|
/// Create a REST client configured for Discord API.
pub fn new_rest_client(
  token? : String,
  api? : String = api_base,
  timeout_ms? : Int = default_timeout_ms,
) -> RestClient {
  let rest = RestClient::new(options=rest_options(api~, timeout_ms~))
  match token {
    Some(token) => rest.with_token(token)
    None => rest
  }
}

///|
/// Create grouped API modules backed by a REST client.
pub fn new_api(rest : RestClient) -> API {
  API::new(rest)
}

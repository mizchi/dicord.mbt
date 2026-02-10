///|
pub struct WebhooksAPI {
  rest : RestClient
}

///|
pub fn WebhooksAPI::new(rest : RestClient) -> WebhooksAPI {
  { rest, }
}

///|
fn webhook_query(wait : Bool, thread_id : String?) -> Array[(String, String)] {
  let query : Array[(String, String)] = []
  if wait {
    query.push(("wait", "true"))
  }
  if thread_id is Some(thread_id) {
    query.push(("thread_id", thread_id))
  }
  query
}

///|
pub async fn WebhooksAPI::execute(
  self : WebhooksAPI,
  id : String,
  token : String,
  body : Json,
  wait? : Bool = false,
  thread_id? : String,
) -> Result[Json, RestError] {
  self.rest.post(
    route_webhook(id, token),
    options=request_options(
      auth_mode=SkipAuth,
      query=webhook_query(wait, thread_id),
      body~,
    ),
  )
}

///|
pub async fn WebhooksAPI::get_message(
  self : WebhooksAPI,
  id : String,
  token : String,
  message_id : String,
  thread_id? : String,
) -> Result[Json, RestError] {
  self.rest.get(
    route_webhook_message(id, token, message_id),
    options=request_options(
      auth_mode=SkipAuth,
      query=webhook_query(false, thread_id),
    ),
  )
}

///|
pub async fn WebhooksAPI::edit_message(
  self : WebhooksAPI,
  id : String,
  token : String,
  message_id : String,
  body : Json,
) -> Result[Json, RestError] {
  self.rest.patch(
    route_webhook_message(id, token, message_id),
    options=request_options(auth_mode=SkipAuth, body~),
  )
}

///|
pub async fn WebhooksAPI::delete_message(
  self : WebhooksAPI,
  id : String,
  token : String,
  message_id : String,
  thread_id? : String,
) -> Result[Json, RestError] {
  self.rest.delete(
    route_webhook_message(id, token, message_id),
    options=request_options(
      auth_mode=SkipAuth,
      query=webhook_query(false, thread_id),
    ),
  )
}

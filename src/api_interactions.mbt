///|
pub struct InteractionsAPI {
  rest : RestClient
}

///|
pub fn InteractionsAPI::new(rest : RestClient) -> InteractionsAPI {
  { rest, }
}

///|
pub async fn InteractionsAPI::reply(
  self : InteractionsAPI,
  interaction_id : String,
  interaction_token : String,
  body : Json,
  auth_mode? : AuthMode = UseClientToken,
) -> Result[Json, RestError] {
  self.rest.post(
    route_interaction_callback(interaction_id, interaction_token),
    options=request_options(auth_mode~, body~),
  )
}

///|
pub async fn InteractionsAPI::get_original_response(
  self : InteractionsAPI,
  application_id : String,
  interaction_token : String,
) -> Result[Json, RestError] {
  self.rest.get(
    route_webhook_message(application_id, interaction_token, "@original"),
    options=request_options(auth_mode=SkipAuth),
  )
}

///|
pub async fn InteractionsAPI::edit_reply(
  self : InteractionsAPI,
  application_id : String,
  interaction_token : String,
  body : Json,
) -> Result[Json, RestError] {
  self.rest.patch(
    route_webhook_message(application_id, interaction_token, "@original"),
    options=request_options(auth_mode=SkipAuth, body~),
  )
}

///|
pub async fn InteractionsAPI::delete_reply(
  self : InteractionsAPI,
  application_id : String,
  interaction_token : String,
) -> Result[Json, RestError] {
  self.rest.delete(
    route_webhook_message(application_id, interaction_token, "@original"),
    options=request_options(auth_mode=SkipAuth),
  )
}

///|
pub async fn InteractionsAPI::follow_up(
  self : InteractionsAPI,
  application_id : String,
  interaction_token : String,
  body : Json,
) -> Result[Json, RestError] {
  self.rest.post(
    route_webhook(application_id, interaction_token),
    options=request_options(auth_mode=SkipAuth, query=[("wait", "true")], body~),
  )
}

///|
pub async fn InteractionsAPI::get_followup_message(
  self : InteractionsAPI,
  application_id : String,
  interaction_token : String,
  message_id : String,
) -> Result[Json, RestError] {
  self.rest.get(
    route_webhook_message(application_id, interaction_token, message_id),
    options=request_options(auth_mode=SkipAuth),
  )
}

///|
pub async fn InteractionsAPI::edit_followup_message(
  self : InteractionsAPI,
  application_id : String,
  interaction_token : String,
  message_id : String,
  body : Json,
) -> Result[Json, RestError] {
  self.rest.patch(
    route_webhook_message(application_id, interaction_token, message_id),
    options=request_options(auth_mode=SkipAuth, body~),
  )
}

///|
pub async fn InteractionsAPI::delete_followup_message(
  self : InteractionsAPI,
  application_id : String,
  interaction_token : String,
  message_id : String,
) -> Result[Json, RestError] {
  self.rest.delete(
    route_webhook_message(application_id, interaction_token, message_id),
    options=request_options(auth_mode=SkipAuth),
  )
}

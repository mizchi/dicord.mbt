///|
test "new_rest_client" {
  let rest = new_rest_client(token="abc")
  let prepared = rest.prepare_request(
    request_method_get(),
    "/users/@me",
    request_options(),
  )
  inspect(prepared.url, content="https://discord.com/api/v10/users/@me")
  inspect(prepared.headers.get("Authorization"), content="Some(\"Bot abc\")")
}

///|
test "new_api" {
  let api = new_api(new_rest_client())
  inspect(api.channels.rest.options.api, content="https://discord.com/api/v10")
}

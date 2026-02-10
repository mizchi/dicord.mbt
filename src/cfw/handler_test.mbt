///|
test "resolve channel id" {
  inspect(
    resolve_channel_id(Some("query"), Some("env")),
    content="Some(\"query\")",
  )
  inspect(resolve_channel_id(None, Some("env")), content="Some(\"env\")")
  inspect(resolve_channel_id(None, None), content="None")
}

///|
test "resolve content" {
  inspect(resolve_content(Some("hello")), content="hello")
  inspect(resolve_content(None), content="hello from discord-cf-mbt")
}

///|
test "build message body" {
  inspect(
    build_message_body("ping"),
    content="Object({\"content\": String(\"ping\")})",
  )
}

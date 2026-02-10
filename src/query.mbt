///|
extern "js" fn encode_uri_component(value : String) -> String =
  #| (value) => encodeURIComponent(value)

///|
pub fn encode_query(params : Array[(String, String)]) -> String {
  if params.is_empty() {
    return ""
  }
  let builder = StringBuilder::new()
  for index, entry in params {
    let (key, value) = entry
    if index > 0 {
      builder.write_char('&')
    }
    builder.write_string(encode_uri_component(key))
    builder.write_char('=')
    builder.write_string(encode_uri_component(value))
  }
  builder.to_string()
}

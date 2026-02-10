///|
extern "js" fn ffi_fetch_text(
  meth : String,
  url : String,
  headers_json : String,
  body : String?,
  timeout_ms : Int,
) -> @js_async.Promise[FetchResponse] =
  #| async (meth, url, headersJson, body, timeoutMs) => {
  #|   const headers = JSON.parse(headersJson);
  #|   const controller = new AbortController();
  #|   const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
  #|   try {
  #|     const response = await fetch(url, {
  #|       method: meth,
  #|       headers,
  #|       body: body ?? undefined,
  #|       signal: controller.signal,
  #|     });
  #|     const text = await response.text();
  #|     return {
  #|       ok: response.ok,
  #|       status: response.status,
  #|       content_type: response.headers.get("content-type") ?? undefined,
  #|       body: text,
  #|     };
  #|   } finally {
  #|     clearTimeout(timeoutId);
  #|   }
  #| }

///|
pub struct RestOptions {
  api : String
  headers : Map[String, String]
  timeout_ms : Int
}

///|
pub fn default_rest_headers() -> Map[String, String] {
  { "User-Agent": default_user_agent }
}

///|
pub fn default_rest_options() -> RestOptions {
  {
    api: api_base,
    headers: default_rest_headers(),
    timeout_ms: default_timeout_ms,
  }
}

///|
pub fn rest_options(
  api? : String = api_base,
  headers? : Map[String, String] = default_rest_headers(),
  timeout_ms? : Int = default_timeout_ms,
) -> RestOptions {
  { api, headers, timeout_ms }
}

///|
pub struct RestClient {
  options : RestOptions
  token : String?
}

///|
pub fn RestClient::new(
  options? : RestOptions = default_rest_options(),
) -> RestClient {
  { options, token: None }
}

///|
pub fn RestClient::with_token(self : RestClient, token : String) -> RestClient {
  { options: self.options, token: Some(token) }
}

///|
pub async fn RestClient::get(
  self : RestClient,
  route : String,
  options? : RequestOptions = request_options(),
) -> Result[Json, RestError] {
  self.request(MethodGet, route, options)
}

///|
pub async fn RestClient::post(
  self : RestClient,
  route : String,
  options? : RequestOptions = request_options(),
) -> Result[Json, RestError] {
  self.request(MethodPost, route, options)
}

///|
pub async fn RestClient::put(
  self : RestClient,
  route : String,
  options? : RequestOptions = request_options(),
) -> Result[Json, RestError] {
  self.request(MethodPut, route, options)
}

///|
pub async fn RestClient::patch(
  self : RestClient,
  route : String,
  options? : RequestOptions = request_options(),
) -> Result[Json, RestError] {
  self.request(MethodPatch, route, options)
}

///|
pub async fn RestClient::delete(
  self : RestClient,
  route : String,
  options? : RequestOptions = request_options(),
) -> Result[Json, RestError] {
  self.request(MethodDelete, route, options)
}

///|
pub fn RestClient::prepare_request(
  self : RestClient,
  meth : RequestMethod,
  route : String,
  options : RequestOptions,
) -> PreparedRequest {
  let query = encode_query(options.query)
  let url = if query == "" {
    "\{self.options.api}\{route}"
  } else {
    let separator = if route.contains("?") { "&" } else { "?" }
    "\{self.options.api}\{route}\{separator}\{query}"
  }
  let headers = self.options.headers.copy()
  for key, value in options.headers {
    headers.set(key, value)
  }
  match options.auth_mode {
    UseClientToken =>
      match self.token {
        Some(token) => headers.set("Authorization", "Bot \{token}")
        None => ()
      }
    UseToken(token) => headers.set("Authorization", "Bot \{token}")
    SkipAuth => ()
  }
  let body = match options.body {
    Some(json) => {
      headers.set("Content-Type", "application/json")
      Some(json.stringify())
    }
    None => None
  }
  { meth, url, headers, body }
}

///|
pub async fn RestClient::request(
  self : RestClient,
  meth : RequestMethod,
  route : String,
  options : RequestOptions,
) -> Result[Json, RestError] {
  let prepared = self.prepare_request(meth, route, options)
  let headers_json = headers_to_json_string(prepared.headers)
  let fetch_result = try? ffi_fetch_text(
    request_method_to_string(prepared.meth),
    prepared.url,
    headers_json,
    prepared.body,
    self.options.timeout_ms,
  ).wait()
  match fetch_result {
    Err(err) => Err(Network(err.to_string()))
    Ok(response) => decode_fetch_response(response)
  }
}

///|
fn request_method_to_string(meth : RequestMethod) -> String {
  match meth {
    MethodGet => "GET"
    MethodPost => "POST"
    MethodPut => "PUT"
    MethodPatch => "PATCH"
    MethodDelete => "DELETE"
  }
}

///|
fn headers_to_json_string(headers : Map[String, String]) -> String {
  let values = headers.map((_, value) => Json::string(value))
  Json::object(values).stringify()
}

///|
fn parse_error_message(body : String) -> String {
  if body == "" {
    return "Unknown error"
  }
  let parsed = try? @json.parse(body)
  match parsed {
    Ok(Object(obj)) =>
      match obj.get("message") {
        Some(String(message)) => message
        _ => body
      }
    _ => body
  }
}

///|
fn decode_success_response(response : FetchResponse) -> Result[Json, RestError] {
  if response.body == "" {
    return Ok(Json::null())
  }
  let is_json = match response.content_type {
    Some(content_type) => content_type.contains("application/json")
    None => false
  }
  if not(is_json) {
    return Ok(Json::string(response.body))
  }
  let parsed = try? @json.parse(response.body)
  match parsed {
    Ok(json) => Ok(json)
    Err(err) => Err(DecodeError(err.to_string()))
  }
}

///|
fn decode_fetch_response(response : FetchResponse) -> Result[Json, RestError] {
  if response.ok {
    decode_success_response(response)
  } else {
    Err(ApiError(response.status, parse_error_message(response.body)))
  }
}

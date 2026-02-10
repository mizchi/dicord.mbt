///|
pub enum RequestMethod {
  MethodGet
  MethodPost
  MethodPut
  MethodPatch
  MethodDelete
} derive(Show, Eq)

///|
pub fn request_method_get() -> RequestMethod {
  MethodGet
}

///|
pub enum AuthMode {
  UseClientToken
  UseToken(String)
  SkipAuth
} derive(Show, Eq)

///|
pub fn auth_mode_token(token : String) -> AuthMode {
  UseToken(token)
}

///|
pub enum RestError {
  Network(String)
  ApiError(Int, String)
  DecodeError(String)
} derive(Show, Eq)

///|
pub struct RequestOptions {
  auth_mode : AuthMode
  body : Json?
  query : Array[(String, String)]
  headers : Map[String, String]
}

///|
pub fn request_options(
  auth_mode? : AuthMode = UseClientToken,
  body? : Json,
  query? : Array[(String, String)] = [],
  headers? : Map[String, String] = {},
) -> RequestOptions {
  { auth_mode, body, query, headers }
}

///|
pub(all) struct FetchResponse {
  ok : Bool
  status : Int
  content_type : String?
  body : String
}

///|
pub(all) struct PreparedRequest {
  meth : RequestMethod
  url : String
  headers : Map[String, String]
  body : String?
}

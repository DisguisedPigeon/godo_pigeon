import app/models/item.{type Item}
import app/pages/error
import app/pages/layout
import gleam/bool
import lustre/element
import wisp

pub type Context {
  Context(items: List(Item))
}

pub fn middleware(
  req: wisp.Request,
  _ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  use <- default_responses

  handle_request(req)
}

pub fn default_responses(handle_request: fn() -> wisp.Response) -> wisp.Response {
  let response = handle_request()

  use <- bool.guard(when: response.body != wisp.Empty, return: response)

  case response.status {
    404 | 405 ->
      error.error("404", "Page not found")
      |> layout.layout
      |> element.to_string_builder()
      |> wisp.html_body(response, _)

    400 | 422 ->
      error.error("400", "Bad request")
      |> layout.layout
      |> element.to_string_builder()
      |> wisp.html_body(response, _)

    413 ->
      error.error("413", "Request entity too large")
      |> layout.layout
      |> element.to_string_builder()
      |> wisp.html_body(response, _)

    418 ->
      error.error("418", "I'm a teapot")
      |> layout.layout
      |> element.to_string_builder()
      |> wisp.html_body(response, _)

    500 ->
      error.error("500", "Internal server error")
      |> layout.layout
      |> element.to_string_builder()
      |> wisp.html_body(response, _)

    _ -> response
  }
}

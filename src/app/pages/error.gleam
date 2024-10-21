import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn error(code, text) -> Element(t) {
  case code {
    "" ->
      html.main([attribute.class("container")], [
        html.h1([], [element.text(text)]),
      ])
    _ ->
      html.main([attribute.class("container")], [
        html.div([attribute.role("group")], [
          html.h1([], [
            html.mark([], [element.text(code)]),
            element.text(" " <> text),
          ]),
        ]),
      ])
  }
}

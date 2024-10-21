import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn layout(elements: Element(t)) -> Element(t) {
  html.html([attribute.attribute("data-theme", "dark")], [
    html.head([], [
      html.title([], "Todo App in Gleam"),
      html.meta([
        attribute.name("viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1"),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href(
          "https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css",
        ),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href(
          "https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.colors.min.css",
        ),
      ]),
    ]),
    html.body([], [
      html.header([attribute.class("container-fluid")], [
        html.nav([], [
          html.ul([], [
            html.li([], [html.strong([], [html.text("Godo Pigeon")])]),
          ]),
          html.ul([], [
            html.li([], [html.a([attribute.href("/")], [html.text("Home")])]),
            html.li([], [
              html.a([attribute.href("/kitty")], [html.text("Cute cat")]),
            ]),
          ]),
        ]),
      ]),
      elements,
    ]),
  ])
}

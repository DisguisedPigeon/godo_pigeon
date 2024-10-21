import app/models/item.{type Item}
import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg

pub fn root(items: List(Item)) -> Element(t) {
  html.main([attribute.class("container")], [
    html.h1([], [element.text("Home")]),
    todos_input(),
    html.form(
      [
        attribute.method("POST"),
        attribute.action("/items/save-many"),
        attribute.id("outer"),
      ],
      [
        html.fieldset([], [
          html.legend([], [html.text("Todos:")]),
          ..todos(items)
        ]),
        html.nav([], [
          html.ul([], [
            html.li([], [
              html.button(
                [
                  attribute.type_("submit"),
                  attribute.value("Submit"),
                  attribute.attribute("form", "outer"),
                ],
                [html.text("Save")],
              ),
            ]),
          ]),
          html.ul([], []),
        ]),
      ],
    ),
  ])
}

fn todos_input() -> Element(t) {
  html.form(
    [
      attribute.method("POST"),
      attribute.action("/items/create"),
      attribute.id("new"),
    ],
    [
      html.fieldset([attribute.role("group")], [
        html.input([
          attribute.name("todo_title"),
          attribute.placeholder("To-do description"),
          attribute.autofocus(True),
        ]),
        html.input([
          attribute.type_("submit"),
          attribute.value("Submit"),
          attribute.attribute("form", "new"),
        ]),
      ]),
    ],
  )
}

fn todos(items: List(Item)) -> List(Element(t)) {
  case items {
    [] -> todos_empty()
    _ -> items |> list.map(item)
  }
}

fn item(item: Item) -> Element(t) {
  html.article([], [
    html.nav([], [
      html.ul([], [
        html.li([], [
          html.input([
            attribute.name("checked_" <> item.title),
            attribute.checked(item.status |> item.item_status_to_bool),
            attribute.type_("checkbox"),
          ]),
          html.text(item.title),
        ]),
      ]),
      html.ul([], [
        html.li([], [
          html.button(
            [
              attribute.type_("submit"),
              attribute.value("Submit"),
              attribute.form_method("POST"),
              attribute.form_action("/items/" <> item.id <> "?_method=DELETE"),
            ],
            [svg_icon_delete()],
          ),
        ]),
        html.li([], [html.p([], [html.text(" ")])]),
      ]),
    ]),
  ])
}

fn todos_empty() -> List(Element(t)) {
  [html.p([], [element.text("No todos")])]
}

fn svg_icon_delete() -> Element(t) {
  html.svg([attribute.width(24), attribute.attribute("viewBox", "0 0 24 24")], [
    svg.path([
      attribute.attribute("fill", "currentColor"),
      attribute.attribute(
        "d",
        "M9,3V4H4V6H5V19A2,2 0 0,0 7,21H17A2,2 0 0,0 19,19V6H20V4H15V3H9M9,8H11V17H9V8M13,8H15V17H13V8Z",
      ),
    ]),
  ])
}

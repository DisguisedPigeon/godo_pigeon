import app/models/item.{type Item, create_item}
import app/web.{type Context, Context}
import gleam/dynamic
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import wisp.{type Request, type Response}

type ItemsJson {
  ItemsJson(id: String, title: String, completed: Bool)
}

pub fn post_create_item(req: Request, ctx: Context) {
  use form <- wisp.require_form(req)

  let current_items = ctx.items

  let result = {
    use item_title <- result.try(list.key_find(form.values, "todo_title"))
    let new_item = create_item(None, item_title, False)
    list.append(current_items, [new_item])
    |> todos_to_json
    |> Ok
  }

  case result {
    Ok(todos) -> {
      wisp.redirect("/")
      |> wisp.set_cookie(req, "items", todos, wisp.PlainText, 60 * 60 * 24)
    }
    Error(_) -> {
      wisp.bad_request()
    }
  }
}

pub fn delete_item(req: Request, ctx: Context, item_id: String) {
  let current_items = ctx.items

  let json_items = {
    list.filter(current_items, fn(item) { item.id != item_id })
    |> todos_to_json
  }
  wisp.redirect("/")
  |> wisp.set_cookie(req, "items", json_items, wisp.PlainText, 60 * 60 * 24)
}

pub fn post_save_items(req: Request, ctx: Context) {
  use form <- wisp.require_form(req)
  let old_items = ctx.items

  let after_true_todos =
    list.map(form.values, fn(form_item) {
      case form_item {
        #("checked_" <> title, _) -> {
          Some(create_item(None, title, True))
        }
        #(_, _) -> None
      }
    })
    |> list.fold([], fn(acc, val) {
      case val {
        Some(v) -> [v, ..acc]
        _ -> acc
      }
    })

  let changed_to_true =
    after_true_todos |> list.filter(fn(e) { !list.contains(old_items, e) })

  let changed_to_false =
    old_items
    |> list.filter_map(fn(e) {
      case
        { e.status == item.Completed }
        && { !list.contains(after_true_todos, e) }
      {
        True -> Ok(item.Item(..e, status: item.Uncompleted))
        _ -> Error(Nil)
      }
    })

  let changed = list.append(changed_to_true, changed_to_false)

  let new_items =
    list.map(old_items, fn(e) {
      case list.find(changed, fn(o) { e.title == o.title }) {
        Ok(e) -> e
        Error(Nil) -> e
      }
    })

  let todos =
    new_items
    |> todos_to_json

  wisp.redirect("/")
  |> wisp.set_cookie(req, "items", todos, wisp.PlainText, 60 * 60 * 24)
}

pub fn patch_toggle_todo(req: Request, ctx: Context, item_id: String) {
  let current_items = ctx.items

  let result = {
    use _ <- result.try(
      list.find(current_items, fn(item) { item.id == item_id }),
    )
    list.map(current_items, fn(item) {
      case item.id == item_id {
        True -> item.toggle_todo(item)
        False -> item
      }
    })
    |> todos_to_json
    |> Ok
  }

  case result {
    Ok(json_items) ->
      wisp.redirect("/")
      |> wisp.set_cookie(req, "items", json_items, wisp.PlainText, 60 * 60 * 24)
    Error(_) -> wisp.bad_request()
  }
}

pub fn items_middleware(
  req: Request,
  _ctx: Context,
  handle_request: fn(Context) -> Response,
) {
  let parsed_items = {
    case wisp.get_cookie(req, "items", wisp.PlainText) {
      Ok(json_string) -> {
        let decoder =
          dynamic.decode3(
            ItemsJson,
            dynamic.field("id", dynamic.string),
            dynamic.field("title", dynamic.string),
            dynamic.field("completed", dynamic.bool),
          )
          |> dynamic.list

        let result = json.decode(json_string, decoder)
        case result {
          Ok(items) -> items
          Error(_) -> []
        }
      }
      Error(_) -> []
    }
  }

  let items = create_items_from_json(parsed_items)

  let ctx = Context(items: items)

  handle_request(ctx)
}

fn create_items_from_json(items: List(ItemsJson)) -> List(Item) {
  items
  |> list.map(fn(item) {
    let ItemsJson(id, title, completed) = item
    create_item(Some(id), title, completed)
  })
}

fn todos_to_json(items: List(Item)) -> String {
  "["
  <> items
  |> list.map(item_to_json)
  |> string.join(",")
  <> "]"
}

fn item_to_json(item: Item) -> String {
  json.object([
    #("id", json.string(item.id)),
    #("title", json.string(item.title)),
    #("completed", json.bool(item.item_status_to_bool(item.status))),
  ])
  |> json.to_string
}

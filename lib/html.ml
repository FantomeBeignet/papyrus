open Core

let convert_to_html_path link =
  let with_slash =
    match String.sub link ~pos:0 ~len:1 with "/" -> link | _ -> "/" ^ link
  in
  if String.length with_slash < 5 then link ^ ".html"
  else
    match String.sub with_slash ~pos:(String.length link - 6) ~len:5 with
    | ".html" -> with_slash
    | _ -> with_slash ^ ".html"

let extract_link_target link =
  let open Cmarkit in
  match Inline.Link.reference link with
  | `Inline (def, _) -> (
      match Link_definition.dest def with
      | Some (dest, _) -> Some dest
      | _ -> None)
  (* TODO: Handle non inline cases *)
  | _ -> None

let remap_links (config: Config.t) doc =
  let links_map = Config.Routes.to_map config.routes in
  let open Cmarkit in
  let inline links_map _ = function
    | Inline.Link (l, meta) ->
        let target =
          match extract_link_target l with
          | None -> "/"
          | Some t -> (
              match
                Map.find links_map
                  (String.strip ~drop:(fun c -> Char.equal c '"') t)
              with
              | Some a -> Utils.concat_paths config.base_url a |> convert_to_html_path
              | None -> "/")
        in
        let node = (target, Meta.make ()) in
        let reference =
          `Inline (Link_definition.make ~dest:node (), Meta.make ())
        in
        let new_link = Inline.Link.make (Inline.Link.text l) reference in
        Mapper.ret (Inline.Link (new_link, meta))
    | _ -> Mapper.default
  in
  let mapper = Mapper.make ~inline:(inline links_map) () in
  Mapper.map_doc mapper doc

let render_page ~(config : Config.t) content =
  let lang = config.language
  and title = config.title
  and description = config.description
  and authors = config.authors in
  let doc = remap_links config (Cmarkit.Doc.of_string content) in
  let r = Cmarkit_html.renderer ~safe:false () in
  let buffer_add_doc = Cmarkit_renderer.buffer_add_doc r in
  let buffer_add_string = Cmarkit_html.buffer_add_html_escaped_string in
  let buffer_add_authors b authors =
    List.iter
      ~f:(fun a ->
        Buffer.add_string b
          (Printf.sprintf {|<meta name="author" content="%s"|} a))
      authors
  in
  Printf.kbprintf Buffer.contents (Buffer.create 1024)
    {|<html lang="%s">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>%a</title>
  <meta name="description" content="%a" />
  %a
</head>
<body>
%a</body>
</html>|}
    lang buffer_add_string title buffer_add_string description
    buffer_add_authors authors buffer_add_doc doc

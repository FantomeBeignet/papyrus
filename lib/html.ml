open Markup

let make_head ~title ~description ~authors =
  [%string
    {|<head>
    <meta charset="utf-8" />
    <title>%{title}</title>
    <meta name="description" content="%{description}">
    %{String.concat "\n" (List.map (fun a -> Printf.sprintf "<meta name=\"author\" content=\"%s\" />" a) authors)}
</head>|}]

let make_document ~language ~title ~description ~authors content =
  [%string
    {|<html lang="%{language}">
    %{make_head ~title ~description ~authors}
    <body>
        <div class="content">
          %{content}
        </div>
    </body>
</html>|}]

let prettify content =
  content |> string |> parse_html |> signals |> pretty_print |> write_html
  |> to_string

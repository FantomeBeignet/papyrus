let render_page ~lang ~title ~description ~authors content = 
  let doc = Cmarkit.Doc.of_string content in
  let r = Cmarkit_html.renderer ~safe:false () in
  let buffer_add_doc = Cmarkit_renderer.buffer_add_doc r in
  let buffer_add_string = Cmarkit_html.buffer_add_html_escaped_string in
  let buffer_add_authors b authors = 
    List.iter (fun a -> Buffer.add_string b (Printf.sprintf {|<meta name="author" content="%s"|} a)) authors;
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
    lang buffer_add_string title buffer_add_string description buffer_add_authors authors buffer_add_doc doc

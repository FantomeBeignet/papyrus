open Core

let build =
  Command.basic ~summary:"Build the site into static HTML"
    (Command.Param.return (fun () -> print_endline "build"))

let dev =
  Command.basic ~summary:"Run the dev server"
    (Command.Param.return (fun () -> print_endline "dev"))

let papyrus =
  Command.group ~summary:"Create a documentation site from markdown"
    [ ("build", build); ("dev", dev) ]

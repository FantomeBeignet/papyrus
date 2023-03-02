open Core

let build =
  Command.basic ~summary:"Build the site into static HTML"
    (Command.Param.return (fun () -> print_endline "build"))

let dev =
  Command.basic ~summary:"Run the dev server"
    (Command.Param.return (fun () -> print_endline "dev"))

let init =
  Command.basic ~summary:"Initialize a Papyrus project"
    (Command.Param.return (fun () -> Init.init_command))

let papyrus =
  Command.group ~summary:"Create a documentation site from markdown"
    [ ("build", build); ("dev", dev); ("init", init) ]

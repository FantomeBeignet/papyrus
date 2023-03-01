open Core

let build =
  Command.basic ~summary:"Build the site into static HTML"
    (Command.Param.return (fun () -> print_endline "build"))

let dev =
  Command.basic ~summary:"Run the dev server"
    (Command.Param.return (fun () -> print_endline "dev"))

let init =
  let open Command.Let_syntax in
  Command.basic ~summary:"Initialize a Papyrus project"
    [%map_open
      let dir = anon ("dir" %: string) in
      fun () -> Printf.printf "init %s" dir]

let papyrus =
  Command.group ~summary:"Create a documentation site from markdown"
    [ ("build", build); ("dev", dev); ("init", init) ]

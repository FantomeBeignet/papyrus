# Papyrus

Generate a static documentation site from plain Markdown.

## Usage

Start by creating a Papyrus project with the `init` flag:

```shell
papyrus init
```

This will prompt you for a project name and create a directory with the same name. You will also be asked if you want to create a `.gitignore` file for the build directory. This is recommended.

The `init` command will create the following directory structure:

```shell
project_name/
├── project_name.papyrus
├── _papyrus/
└── src/
    └── content/
```

The `project_name.papyrus` file is the configuration file for your project. The `_papyrus` directory is where the build files will be stored. The `src/content` directory is where you will store your Markdown files. Other files for your project can be stored in the `src` directory.

To build your project, run the `build` command:

```shell
papyrus build
```

## Configuration

The `.papyrus` file uses S-expressions to configure the project. The following options are available:

```lisp
((name "My Project")
 (description "A description of my project")
 (authors ("John Doe" "Jane Doe")) 
 (language "en")
 (root_dir "")
 (routes ((index "index.md")
          (about "about.md")
          (contact "contact.md")
          (nested/blog "blog.md")))
)
```

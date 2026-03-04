# SmallAdvancedTextEditor

A text editor with syntax highlighting for GNUstep (Linux) and macOS. Uses [SmallStepLib](../SmallStepLib) for app lifecycle, menus, window style, and file dialogs.

## Supported languages

Syntax highlighting is applied automatically from the file extension when you open or save a file.

- **Top languages:** C, C++, Java, C#, JavaScript, TypeScript, Python, PHP, Ruby, Swift, Go  
- **Additional:** Objective-C, Makefile, Scala, Raku, Lua, Godot Script (.gd), Assembly (.s, .asm, .as)

## Build

1. Build and install SmallStepLib:
   ```bash
   cd ../SmallStepLib && make && make install
   ```
2. Build the app:
   ```bash
   cd ../SmallAdvancedTextEditor && make
   ```

Run with `openapp SmallAdvancedTextEditor` (GNUstep) or run the app bundle on macOS.

## Usage

- **New** – new untitled document  
- **Open…** – open a file (language detected from extension)  
- **Save** / **Save As…** – save as UTF-8  

Highlighting uses fixed-width font, with colors for keywords, strings, comments, numbers, and (for C/C++/ObjC) preprocessor directives.

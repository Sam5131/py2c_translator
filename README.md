# Py2C: A Basic Python-to-C Translator 🐍➡️💻

A mini compiler project built for the **Compiler Design Lab** that translates a simplified subset of **Python code to equivalent C code** using **Lex (Flex)** and **Yacc (Bison)**.

## 📌 Overview

`Py2C` is a source-to-source translator that performs:
- **Lexical Analysis** of Python syntax using Flex
- **Syntax Parsing** using Bison to generate C-compatible syntax
- **Code Generation** that outputs a `.c` file equivalent of the input `.py` file

The project focuses on a **restricted subset of Python** — handling variable declarations, loops, conditionals, print statements, and basic expressions — and maps them to equivalent C constructs.

## 💡 Features

- Translates:
  - `print()` ➡️ `printf()`
  - `if`, `elif`, `else` ➡️ `if`, `else if`, `else`
  - `for` loops ➡️ C-style `for` loops
  - `while` loops ➡️ `while`
  - `int`, `float`, `char` variable assignments ➡️ C declarations
- Handles indentation-based Python to bracket-based C conversion
- Generates compilable `.c` file from `.py` input

## 🏗️ Architecture

```bash
+------------------+
|  Python Source   |   (.py)
+--------+---------+
         |
         v
+--------+---------+
|  Lexical Analyzer|   (lexer.l using Flex)
+--------+---------+
         |
         v
+--------+---------+
|  Syntax Parser   |   (parser.y using Bison)
+--------+---------+
         |
         v
+--------+---------+
| C Code Generator |   (parser actions)
+--------+---------+
         |
         v
+------------------+
|  Translated .c   |
+------------------+

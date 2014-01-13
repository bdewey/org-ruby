# Code blocks in lists
## No spaces in code block

- List starts
 + Block without indentation
   #+begin_example
puts "test"
   #+end_example
- List continues here
 + and finished here

 * List starts
  * Block without indentation
```
puts "test"
```
 * List continues here
  * and finished here

## Code block indented

- List starts
 + Block without indentation
   #+begin_example ruby
  puts "test"
   #+end_example
- List continues here
 + and finished here

 * List starts
  * Block without indentation
```
  puts "test"
```
 * List continues here
  * and finished here

## Indentation level in example block

- Indentation of a begin_example code block
 #+begin_example
   (+ 3 5)
 #+end_example


 * Indentation of a begin_example code block
```
    (+ 3 5)
```

# normal list should work

 * one
text in the same line

This is a paragraph
  * A sublist
   * Another sublist

Sublist paragraph
  * 2nd sublist
   * 2nd sublist item

Paragraph from 2nd sublist
 * two
  * a new list

paragraph
  * another sublist
 * final list
# paragraphs in lists should work

 * Foo
  * How does this work?

uno dos tres
  * Should not this be a paragraph?
 * Bar

# begin example in lists should work

 * Foo
```
    class Hello
      def say
        puts 'cheers'
      end
    end
```
 * Bar
```
    This gets lumped in to the above line "Example"
```
 * Hello

# begin quote in lists should work

 * Example
  * Uno
Lorem
A quote!!!
dolor
  * Dos

# tables in lists should work

 * Example
  * Table

This table:
| a | b |
| 0 | 1 |
| 1 | 2 |

 * After the table

The table should be above

# definition lists should work

 * Example
Hello :: Hola
Paragrap continues here
Cuando me desperte, el dinosaurio estaba alli.
Dog :: Perro
Paragraph
  * Last sublist
 * Another list
  * with a sublist

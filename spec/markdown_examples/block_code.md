# Block Code

I need to get block code examples working. In `orgmode`, they look
like this:

```
    def initialize(output)
      @output = output
      @buffer = ""
      @output_type = :start
      @list_indent_stack = []
      @paragraph_modifier = nil

      @logger = Logger.new(STDERR)
      @logger.level = Logger::WARN
    end

```

And now I should be back to normal text.

Putting in another paragraph for good measure.


Code should also get cancelled by a list, thus:

```
This is my code!

Another line!
```

 * My list should cancel this.
 * Another list line.

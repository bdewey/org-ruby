# Removing the prepended comma from Org mode example blocks

As mentioned in [http://orgmode.org/manual/Literal-examples.html](http://orgmode.org/manual/Literal-examples.html),
when at the beginning of the line there is either ",*" or ",#+"
this prepended comma should be removed before parsing.

(Fixes [https://github.com/bdewey/org-ruby/issues/50](https://github.com/bdewey/org-ruby/issues/50))

## Here the prepended comma will be removed.

```org
  ,* Hello
  ,** Goodbye
  , *** Not a headline, but prepended comma still removed.
  ,* I am a headline
```

## Here the prepended comma is should not be removed.

```js
  {
    "one":   1
  , "two":   2
  , "three": 3
  , "four":  4
  }
```

## Here the prepended comma is also removed
Emacs Org mode implementation also removes it.

```ruby
  text = <<TEXT
  ,#+TITLE: Prepended comma world
  ,* Hello world
  More text here
  TEXT
```

## Here the prepended comma will be remove for the `Hello world` headline

```org
  ,  ,* Hi
  ,  
  ,  ,* This will be appended a comma
  ,* Hello world  
  ,  
```

## Here the prepended comma will be removed

```org
  ,#+TITLE: "Hello world"
```

## This will be rendered as normal

```org
  ,,,,,,,,,,,,,,,,,*Hello world
```

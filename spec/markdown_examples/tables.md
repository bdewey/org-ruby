TABLES

Different types of ORG tables.

# Simple table, no header.

| Cell one   | Cell two  |
| Cell three | Cell four |


# Indented table

| Cell one |
| Cell two |

And here's some paragraph content. The line breaks will need to get
removed here, but not for the tables.

# Table with header

| One   | Two   | Three |
| Four  | Five  | Six   |
| Seven | Eight | Nine  |

The separator row should not get printed out.

# Table with complete box

| One   | Two   | Three |
| Four  | Five  | Six   |
| Seven | Eight | Nine  |

Only the first row should be a header row.

# Table with extra lines

| One   | Two    | Three  |
| Four  | Five   | Six    |
| Seven | Eight  | Nine   |
| Ten   | Eleven | Twelve |

Only the first row should be a header row.

# Fix error when table starts with hline (Thanks @til!)
| foo | bar |
|   1 |   2 |
https://github.com/bdewey/org-ruby/pull/34

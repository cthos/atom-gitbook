module.exports =
class RetextSummary
  @formatTree: (tree) ->
    lines = ["Summary", "========="]
    for ele in tree
      line = "- `#{ele.name}"
      if ele.file
        line = line + " <#{ele.file})>"
      line = line + "`"
      if ele.indent > 0
        for i in [1..ele.indent]
          line = " " + line
      lines.push(line)
      
    return lines.join("\n")
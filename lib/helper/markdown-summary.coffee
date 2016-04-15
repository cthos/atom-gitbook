module.exports =
class MarkdownSummary
  @formatTree: (tree) ->
    lines = ["# Summary"]
    for ele in tree
      continue if ele.name == 'Introduction'
      line = "* [#{ele.name}]"
      if ele.file
        line = line + "(#{ele.file})"
      if ele.indent > 0
        for i in [1..ele.indent]
          line = " " + line
      lines.push(line)
      
    return lines.join("\n")
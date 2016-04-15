module.exports =
class AsdocSummary
  @formatTree: (tree) ->
    lines = ["= Summary"]
    for ele in tree
      continue if ele.name == 'Introduction'
      line = ". "
      if ele.file
        line = line + "link:#{ele.file}"
      line = line + "[#{ele.name}]"
      if ele.indent > 0
        dotindent = Math.floor ele.indent / 2
        for i in [1..dotindent]
          line = "." + line
      lines.push(line)
      
    return lines.join("\n")
path = require 'path'
fs = require 'fs-plus'
MDRenderer = require path.join(atom.packages.resolvePackagePath('markdown-preview'), 'lib', 'renderer')

module.exports =
class IncludeParser

  @parseIncludesInText : (text, currentFileDir) ->
    re = new RegExp /(?:\<p\>)?\{\% include ['"]([^\%]+)["'] %\}(?:\<\/p\>)?/gi

    while (arr = re.exec(text)) != null
      continue unless filename = arr[1]

      includePath = path.join(currentFileDir, filename)

      continue unless fs.existsSync(includePath)
      incText = fs.readFileSync(includePath, 'utf-8')
      incText = IncludeParser.parseIncludesInText(incText, includePath) if incText

      text = text.replace(arr[0], incText)
    text

  @rerenderMarkdown : (text, pathToCurrentFile) ->
    promise = new Promise (resolve, reject) ->
      MDRenderer.toHTML(text, pathToCurrentFile, null, (error, html) ->
        resolve(html)
      )
    return promise

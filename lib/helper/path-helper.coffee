path = require 'path'
_ = require 'lodash'
fs = require 'fs'

module.exports = 
class PathHelper
  @possibleExtensions = {
    'markdown' : [".md", ".markdown", ".mdown"],
    'asciidoc' : [".asdoc", ".asciidoc", ".adoc"],
    'retext' : [".rst"]
  }
  
  @findExistingSummaryPath: (basePath) ->
    possibleExtensions = _.flatten(_.values(PathHelper.possibleExtensions));
  
    for ext in possibleExtensions
      summaryName = 'summary' + ext
      summaryPath = path.join(basePath, summaryName)
      return summaryPath if fs.existsSync(summaryPath)
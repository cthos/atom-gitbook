# atom-gitbook package

Plugin provides a Tree view for Gitbook Summary files, along with functionality that entails.

## Features

* Preview Table of Contents from Summary.md
* Auto-toggle Markdown Preview if installed
* Reorder Chapters from the Table of Contents
* Add existing files to the ToC from the tree view
* Add and remove chapters
* Create underlying Markdown file if it doesn't exist

![Demo](doc/img/atom-gitbook.gif)

## Developer instructions.

### Clone the repo

```bash
git clone git@github.com:cthos/atom-gitbook.git
```

### Link it to your gitbook directory

```bash
ln -s /path/to/atom-gitbook ~/.atom/packages/atom-gitbook
```

### NPM Install

```bash
cd atom-gitbook
apm install
```

It might also be necessary to `apm rebuild` from time-to-time as atom gets updated.

#### Problems on Mac

I've been seeing an issue where the package will not rebuild unless you do an `npm install` using node `0.10.35`. I've tested this with `n` to manage the versions, but `nvm` should also work... I think.

More info here: https://www.alextheward.com/blog/apm-rebuild/
# worktree
Organize your development environment when you are using tmux & vim for software development

## Dependencies
1. git
2. tmux
3. vim

## Installation
1. git clone git@github.com:gigorok/worktree.git
2. ln -s worktree/bin/worktree ~/.bin/worktree
3. configure your shell to make ~/.bin folder be available in $PATH
4. prepare your existing repo

## Prepare your repo
Let's assume you have a git repo (at master branch) by path ~/projects/YOUR_REPO_NAME/.git.
Then you have to have the next folder structure ~/projects/YOUR_REPO_NAME/master/.git.

## Usage
To create a new worktree folder go to ~/projects/YOUR_REPO_NAME & run command `worktree new new-feature`.
1. Worktree will create a new folder (new-feature) inside ~/projects/YOUR_REPO_NAME (following git worktree feature).
2. Copy nessessary development config files.
3. If you are using Rails then worktree will ask you about creation of clone of your
development database (if master/config/database.yml exists).
4. Run tmux inside of ~/projects/YOUR_REPO_NAME/new-feature along with VIM

## .copy_files
The file should be present in ~/projects/YOUR_REPO_NAME folder.
This is a plain text file with list of files which should be copyied to the new worktree folder.
Example:
```
.ruby-version
config/database.yml
```

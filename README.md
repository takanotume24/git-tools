## `check_file_size.sh`
Check the size of the file that was the subject of the Git commit.
If you commit a large file, you may run into the following problems
- GitHub and other Git repository hosting services set a limit on the size of files tracked by Git. If a large file is included, it will be rejected during push.
- The Git repository may become bloated, causing Git commands to run slower and the .git directory to become huge.

## Installation
1. Clone this repository to any location.

    ```
    $ git clone git@github.com:takanotume24/git-tools.git
    ```
1. Move to a Git repository that requires a file size check.
    
    ```
    $ cd target_git_repository
    ```

1. Edit `.git/hooks/pre-commit` and include the following.

    ```bash
    #!/bin/bash
    "${HOME}/git-tools/check_file_size.sh"
    ```

## Usage
Run `git commit``. If the size of the file to be committed is too large, it will show an error and abort the commit.
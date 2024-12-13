# COVID-19 pandemic in the US

## Overview

(insert text here)

## Reproducing Results

(insert text here)

## Contributing (git steps)

### Committing changes

1. Run `git pull`

2. Run `git add .` or `git add filename.txt`

3. Run `git commit -m "insert commit message here"`

4. Run `git push`

### Troubleshooting Git Issues

If you get a message that says "Your local changes to teh following would be overwritten by merge:...":

1. Run `git stash`

2. Run `git pull`

3. Run `git stash pop`

4. You should see a message saying there are merge conflicts, and it will list the files with merge conflicts.

5. Open each of the files that it lists (for example, in TextEdit or RStudio). Find all the instances where you see a bunch of greater than >>>>>>> or less than >>>>>>> symbols, or a bunch of equals signs ======= (I am not sure exactly how many, but doing Command + F for 3 should find them). There may be multiple instances of this in one file.

6. Each time you see those symbols, decide which version of the edits you want to keep (or, if you want, try to combine them). Make the changes and remove all the merge conflict text.

7. Save those files. Try running the code to make sure it still works, and fix any bugs if needed.

8. (optional) Run `git status` again.

9. Run `git add <files with merge conflicts>`

10. Run `git commit -m "put some commit message here"`

11. Run `git push`

12. If it doesn't let you push, you will need to run `git pull`. You may need to resolve additional merge conflicts. If that happens, repeat the process.

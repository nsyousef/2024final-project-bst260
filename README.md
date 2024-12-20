# COVID-19 pandemic in the US

## Reproducing Results

### Preparation

All the files you need to reproduce the results are in the `code` directory. Please make sure the working directory is set to the `code` directory (not the root of the repo) when attempting to reproduce results, as all file paths are relative to that directory.

To run the code in this project, you will need the following R libraries:

* httr2

* tidyverse

* lubridate

* plotly

* ggplot2

* dplyr

* tidyr

* readr

* stringr

### Obtaining Data

Most of the raw data is stored in the `raw-data` directory. The case data can be refreshed by running the script `download_case_data.r`.

### Data Wrangling

The data are wrangled in `wrangle.R`. Running this script will produce or update the file `covid_cases_deaths.csv` in the `data` directory. This file contains all the wrangled data needed for the analysis.

### Reproducing Analysis

The final report, along with all code to run the analysis, is stored in `final-project.qmd`. You can run this file or render it. When rendered, it produces an HTML document containing the final report in the `code` directory.

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

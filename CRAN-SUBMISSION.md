# CRAN Submission Checklist

## Before Submission

- [ ] Package name valid (CamelRatiosIndex -- checked with `available::available()`)
- [ ] `DESCRIPTION` complete and accurate
- [ ] All authors have valid emails
- [ ] `License` field valid
- [ ] `URL` and `BugReports` fields valid

## Documentation

- [ ] All exported functions documented with roxygen2
- [ ] All exported functions have `@examples`
- [ ] Vignette included
- [ ] `README.Rmd` renders correctly

## Code Quality

- [ ] `devtools::check()` returns 0 errors, 0 warnings, 0 notes
- [ ] `devtools::test()` passes all tests
- [ ] `devtools::check_rhub()` passes
- [ ] `devtools::check_win_devel()` passes

## CRAN-Specific

- [ ] No files over 5MB
- [ ] No non-ASCII characters
- [ ] No writing to user's filespace
- [ ] All URLs valid
- [ ] `cran-comments.md` updated


ticket: DV-none
****
^^^^^ Commit body above, PR title is the commit subject
<!--commit body should be wrapped at 72 chars as long as this comment-->


## Author Section
<!-- Please only include the relevant section -->

### Fix
If this is a fix, there should be a simple test of "this doesn't work on develop, does work on the fix branch"

### Feature
If manual testing is required, please fill out this table:
| Test Case                                    | How to tell if it works |
| ---                                          | ---                     |
| appfoo handles a PSM with no path prediction | Outputs empty fields    |
| appfoo handles a PSM with path prediction    | Outputs filled fields   |


## Reviewer Section
* [ ] Are there no breaking changes / are the breaking changes documented?
* [ ] Are unit tests added? (or not applicable)
* [ ] Do the edited sections of code match our coding standards
  * e.g. naming conventions adhered, no copy/paste, readable, function names describe the behavior
* [ ] Is the documentation still correct? (function descriptions, readme, etc)

Note: Do not press green "squash and merge" or whatever it may say button, add label `automerge` to cause the pr to be automagically merged with the commit message from the PR.

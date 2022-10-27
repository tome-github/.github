ticket: DV-none
****
^^^^^ Commit body above, PR title is the commit subject
<!--commit body should be wrapped at 72 chars as long as this comment-->


## Testing notes from the author
<!--
Describe what the PR DOES in the commit body above.
Put notes on how to test in this section.

| Test Case                                    | How to tell if it works |
| ---                                          | ---                     |
| appfoo handles a PSM with no path prediction | Outputs empty fields    |
| appfoo handles a PSM with path prediction    | Outputs filled fields   |
-->

## Reviewer Section
* [ ] Are there no breaking changes / are the breaking changes documented?
* [ ] Are unit tests added? (or not applicable)
* [ ] Do the edited sections of code match our coding standards
  * e.g. naming conventions adhered, no copy/paste, readable, function names describe the behavior
* [ ] Is the documentation still correct? (function descriptions, readme, etc)

Note: Do not press green "squash and merge" or whatever it may say button, add label `automerge` to cause the pr to be automagically merged with the commit message from the PR.

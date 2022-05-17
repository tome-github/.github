# How to Contribute

First off, thanks for being interested in bike safety enough to help out!
Bugs, feature requests, and especially pull requests are all appreciated.

## 1. How to get help
Talk to Tome on Slack, or email Tome's Angela Fessler.

## 2. How to report bugs/request features/discuss changes you want to make
If you want to discuss bugs/features, just open a GitHub issue talking about it!
We're happy to discuss features and bugs with you.


## 3. How to Contribute Code
### 3.1. TL;DR:
#### 3.1.1 PR Requirements
  * One feature or fix per PR
  * Add tests for whatever is being added/fixed
#### 3.1.2 Things that would be nice in a PR, but can be fixed at merge time
  * One commit per PR
  * A [good commit message][tpope-commit] in the
    [conventional commit][conventional-commit] format.

PRs will typically be responded to within one to two working days.

[conventional-commit]: https://www.conventionalcommits.org/en/v1.0.0/
[tpope-commit]: https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html


### 3.2 The Slightly Longer and Slightly Idealized PR Process


#### 3.2.1 PR Overview
1. make branch
2. make changes
3. Use linter to follow code standards. TODO tags should be used for anything to edit before merging. The code will build,
   but not successfully lint with these tags.
4. create PR, fill out the PR template.
   Part of this is writing the final commit subject and body.
5. Assign tome-github/authors as reviewer unless there is a reason not to do so.
   If you create the PR you should be assigned to it, and are responsible for following up and making sure it gets merged.
6. Get approval
7. add `automerge` label so the PR is autmagically merged when all the checks pass

#### 3.2.2 Feature branches
  * Make a feature branch off `develop` (remember to pull `develop` first)
      * commit early, commit often, clean it up later
  * When it's good for review, rebase off `develop` and squash all commits, make
    sure there is a good commit message (see above)
  * Start a pull request
  * Resolve issues brought up by reviewers, maybe rebase to keep history clean
  * Use `automerge` label to get PR merged


#### 3.2.3 Commit Messages
We're using the [conventional commit][conventional-commit] format, with the
[config-conventional][config-conventional] standards
```
<type>[optional scope]: <imperative description>

[optional body]

[optional trailer(s)]
ticket: BV-XXX
```
* Type is one of
  * `build`: Changes that affect the build system or external dependencies (Makefiles and such)
  * `ci`: Changes to our CI configuration files and scripts (Jenkins or github ci stuff)
  * `docs`: Documentation only changes
  * `feat`: A new feature
  * `fix`: A bug fix
  * `perf`: A code change that improves performance
  * `refactor`: A code change that neither fixes a bug nor adds a feature
  * `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc)
  * `test`: Adding missing tests or correcting existing tests
  * `chore`: stuff like releases that isn't changing code or documentation
  * `revert`: reverting stuff
* Scope is an optional thing to tell other humans what you were working with.
  * so you could do `docs(readme): improve compilation instructions`, or
    `docs(functions): make function argument docs consistent`


Example:
```
feat(psm_init)!: simplify psm init arguments

BREAKING CHANGE: psm init arguments are passed in a new struct
This was done because there were too many arguments, this makes
the calling code way more readable.
```

  * Title MUST be imperative. See the verbose link (below) for more explanation
  * Title SHOULD try to be under 50 characters, and MUST be below 72.
  * Everything MUST wrap at 72.

Further Reading:
  * Shorter: https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
  * Longer: https://chris.beams.io/posts/git-commit/

[conventional-commit]: https://www.conventionalcommits.org/en/v1.0.0/
[config-conventional]: https://github.com/conventional-changelog/commitlint/tree/master/%40commitlint/config-conventional


#### 3.2.4 Branch names
  * `develop`: The most recent working code
  * `master`: the latest release
  * `hotfix/description`: all hotfixes
  * Feature branch names should just be the commit types defined above

Name your branches `*/short-description[-optional-ticket-number]`.

For example: `docs/contributing` or `fix/something-something-BV-312`.

#### 3.2.5 Versioning
Versioning (*major.minor.patch) is* based off the commit subjects.
  * When there is an exclamation mark in the subject or or `BREAKING CHANGE` in
    the body it bumps the *major* version.
  * When a commit is of type `feat`, it bumps the *minor* version.
  * All other commits bump *patch*.

#### 3.2.6 Continuous Integration (CI) Notes

Currently only the android repos have any CI.
Jenkins will run the tests, run some linting, and report back if it failed.

What Jenkins will do:
  * Runs the jenkinsfile script on every branch when it's pushed
  * Reports build status to Slack
  * If branch is `master` and the tests pass, it runs the release section of the
    script which merges into develop and announces the release to Slack
      * It can do any extra release tasks needed by the repo

#### 3.2.7 Release workflow

Version is tracked in git tags.
Some repos will also have a number in `version.h` or `build.gradle` that is updated at releases.

Everything is managed through `release.sh`, and it uses [standard version][standard-version].

Please read its help, below are partial commands.

##### Process to Release
`release.sh` is called from the repo you want to release.
It can be run in automated or non-automated mode.
The difference is automated pushes the changes, non-automated keeps everything local.

  1. Create branch `release/vMAJOR.MINOR.PATCH`
     * `release.sh [-a] branch`
  2. Update the version and changelog.
     * `release.sh [-a] version`
       * This updates the changelog, version, and does whatever is specified by
       `.versionrc` to update `version.h` and possibly other files
  3. Check changelog against list of commits
     * If you need to edit it you must ammend the commit so there is only one release commit on the release branch.
  3. Create a PR
     * `release.sh [-a] pr`
  2. Do testing, fix any issues
     *  If there are any issues, re-create the release branch after they're fixed.
  3. Tag and merge
     * `release.sh [-a] merge`
       * This will merge the release branch back into develop, fast forward
       master, apply appropriate tag, and delete the release branch.


[standard-version]: https://github.com/conventional-changelog/standard-version

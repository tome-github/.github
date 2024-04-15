#!/usr/bin/env bash
set -euo pipefail

#TODO: hotfix flow
# * create fix/whatever branch off release tag
# * create hotfix branch off release tag
# * PR fix into hotfix
# * create release branch off of hotfix
# * PR release into hotfix, tag, etc
# * merge commit into develop

h () {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [OPTION]... <branch|version|merge>
Create release branches/commit or merge released thing to develop & master/main.
Expected order of operations is to create branch, do testing,
update version/create PRs, and then once the PR is accepted, merge

Available options:
  -h, --help       display this help and exit
  -a, --automatic  push changes automatically
Operations:
    branch: Create the branch release/vMAJOR.MINOR.PATCH
        automated will push the branch after creating it
    version: Update the versions, create the changelog, and commit
        automated will push the commit
        if branch isn't created but we're on develop, create the branch.
    pr: Create a PR either with github cli or by URL
        You *must* use this script to create the PR so we can get the template.
        non-automated will always just give you a URL to click on to create it in a browser
    merge: Merge release branch into develop and master/main and delete branch
        automated will push the branches
EOF
}

msg() {
    echo >&2 -e "${1-}"
}

die() {
    local msg=$1
    local code=${2-1} # default exit status 1
    msg "$msg"
    exit "$code"
}
checkInstalled() {
    tool=$1
    messsage="${2:-I require $tool but it\'s not installed}"
    command -v "$tool" >/dev/null 2>&1 || die "$messsage"
}

checkInstalled standard-version

PR_TEMPLATE=$(cat <<'END_HEREDOC'
* [ ] Changelog accurately represents the changes
* [ ] end to end testing has involved this release branch

Note:
* Do **not** press green "squash and merge" or whatever it may say button,
* Do **not** add automerge.
* **Do** run the `release.sh` merge action!
END_HEREDOC
)

urlencode() {
    # urlencode <string>
    # https://gist.github.com/cdown/1163649

    old_lc_collate=${LC_COLLATE:-}
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

getPRTitle() {
    git log -1 --pretty=%s
}
getRepoName() {
    git config --get remote.origin.url | sed 's/.*tome-github\/\([^.]*\).*/\1/'
}
getCurBranch() {
    git rev-parse --abbrev-ref HEAD
}

branch() {
    curBranch=$(getCurBranch)
    if [[ "$curBranch" != "develop" ]]; then
        msg "\e[31mHEAD was not on develop, switching and to develop\e[0m"
        # TODO: confirm
        git checkout develop >/dev/null
    fi
    git pull >/dev/null
    newVersion=$(standard-version --dry-run | sed -n 's/.*tagging release //p')
    releaseBranch="release/${newVersion}"
    git checkout -b "$releaseBranch"

    if [ "$automatic" = true ]; then
        git push --set-upstream origin "$releaseBranch"
    else
        msg ""
        msg "Because non-automated, please run:\ngit push --set-upstream origin $releaseBranch"
    fi

}

pr() {
    curBranch=$(getCurBranch)
    prTitle="$(getPRTitle)"
    repoName=$(getRepoName)
    if [[ "$curBranch" != "release"* ]]; then
        die "you aren't on a release branch. You should be."
    fi

    if command -v gh >/dev/null && [ "$automatic" = true ] ; then
        gh pr create --base develop --title "$prTitle" --body "$PR_TEMPLATE" -f
    else
        link="https://github.com/tome-github/$repoName/compare/$curBranch?expand=1&title=$(urlencode "$prTitle")&body=$(urlencode "$PR_TEMPLATE")"
        if [ "$automatic" = true ]; then
            msg "click here to make the PR:\n$link"
        else
            msg "After you run 'git push', click here to make the PR:\n$link"
            msg "or run 'release.sh pr' to get the link again"
        fi
    fi
    msg "\n"
    msg "REMEMBER: set yourself as assignee, and set reviewers"
    msg "When the PR is accepted, do the merge operation in release.sh"
}

version() {
    curBranch=$(getCurBranch)
    if [[ "$curBranch" != "develop" && "$curBranch" != "release"* ]]; then
        die "you aren't on a release branch. You should be."
    fi
    if [[ "$curBranch" == "develop" ]]; then
        branch
    fi
    standard-version >/dev/null
    git tag --delete "$(git describe)" >/dev/null

    if [ "$automatic" = true ]; then
        git push
    else
        msg ""
        msg "Because non-automated, please run git push sometime"
    fi

    msg "Edit the changelog for readability/correctness and amend('man git-commit') the release commit with the changes"
    msg "then '$0 pr' to create a PR"
}

merge() {
    curBranch=$(getCurBranch)
    if [[ "$curBranch" != "release"* ]]; then
        die "you aren't on a release branch. You should be."
    fi
    releaseTag="v$(sed -n 's/## \[\([0-9.]*\).*/\1/p' CHANGELOG.md  | head -n1)"

    develop2CurrentCount=$(git rev-list --count --no-merges origin/develop..HEAD)
    # TODO: wrong
    if [[ "$develop2CurrentCount" -gt 1 ]]; then
        die "Too many commits on the release branch, please squash ('git rebase -i develop' or 'gsquash develop')"
    fi

    # try to check if PR is ready
    if command -v gh >/dev/null; then
        if ! gh pr checks >/dev/null; then
            die "PR checks haven't passed"
        fi
    fi

    # create tag, if it already exists on the current commit that's fine else fail.
    if git rev-list -n1 "$releaseTag" >/dev/null 2>&1; then
        # if tag already exists
        if [[ "$(git rev-list -n1 "$releaseTag")" != "$(git rev-list -n1 HEAD)" ]]; then
            # existing tag didn't match
            die "release tag $releaseTag already exists on another commit?"
        fi
    else
        # create release tag
        git tag -m "$releaseTag" "$releaseTag"
    fi

    git checkout develop
    git pull >/dev/null
    res=0
    git merge --ff-only "$releaseTag" &>/dev/null|| res=$?
    if [ ! "$res" -eq "0" ]; then
      msg "couldn't do a fast forward merge of develop, doing a merge commit"
      git merge "$releaseTag" -m "chore(release): merge $releaseTag"
      msg "please confirm develop is merged properly, if it isn't do 'exit 1' and if it is, do 'exit 0'"
      # launch a shell, source user bashrc, but set custom PS1 and unset prompt command
      bash --rcfile <(echo ". ~/.bashrc; unset PROMPT_COMMAND; PS1='confirm good develop merge shell > '") -i
    fi
    if git branch | grep -q main; then
        mainBranch=main
    elif git branch | grep -q master; then
        mainBranch=master
    else
        die "no main/master branch?"
    fi
    git checkout "$mainBranch"
    git pull >/dev/null
    git merge --ff-only "$releaseTag"

    if [ "$automatic" = true ]; then
        git push --no-follow-tags origin develop
        if git ls-remote --exit-code origin "refs/tags/$releaseTag"; then
            git push origin ":$releaseTag"
        fi
        git push --no-follow-tags origin "$mainBranch" "$releaseTag"

        git branch -d "$curBranch"
        sleep 1
        git fetch --prune >/dev/null
    else
        msg ""
        msg "Because non-automated, please do:"
        msg "git push --no-follow-tags origin develop $mainBranch $releaseTag: $curBranch"
        msg ""
        msg "If tag 'already exists', run 'git push origin --delete $releaseTag' and push again"
        msg "Otherwise something weird went wrong, good luck"
    fi
}



doStuff() {
    msg "doing $operation on $repo"

    git fetch --prune >/dev/null

    #figure out if we are ahead or behind remote
    # will be "ahead", "behind", or something like "## develop...origin/develop"
    status=$(git status -sb --porcelain | head -n1 | sed 's/.*\[\([a-z]\+\) [0-9]\+\]$/\1/')

    if [[ "$status" = "ahead" || "$status" = "behind" ]]; then
        die "git current state doesn't match upstream\nHEAD is $status of upstream" 3
    fi

    if [ "$operation" = "branch" ]; then
        branch
    elif [ "$operation" = "version" ]; then
        version
    elif [ "$operation" = "merge" ]; then
        merge
    elif [ "$operation" = "pr" ]; then
        pr
    fi
}

TEMP=$(getopt -o ha --long help,automatic -n "$0" -- "$@")
#shellcheck disable=SC2181
if [ $? != 0 ] ; then
    die "something wrong with getopt"
fi
eval set -- "$TEMP"

automatic=false
while true ; do
    case "$1" in
        -h|--help) help; exit 0 ;;
        -a|--automatic) automatic=true; shift ;;
        --) shift ; break ;;
        *) die "issue parsing args, unexpected argument '$0'!" ;;
    esac
done


if [ "$#" -lt 1 ]; then
    help "need to specify an operation"
fi

operation=$1
shift

# get repo root of cwd
repo=$(git rev-parse --show-toplevel)
cd "$repo"

if [[ "$operation" != "version" && "$operation" != "branch" && "$operation" != "merge" && "$operation" != "pr" ]]; then
    help "invalid operation $operation"
fi

if [ "$automatic" = true ]; then
    automationStatus="automated"
else
    automationStatus="non-automated"
fi

read -e -r -p "Performing $automationStatus $operation on $repo [y/N] " response
case "$response" in
  [yY][eE][sS]|[yY])
    doStuff
    ;;
esac

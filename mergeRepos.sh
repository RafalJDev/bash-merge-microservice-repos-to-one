#!/usr/bin/env bash

# todo declare


function cloneAllRepositories() {
    for httpRepo in "$@" ; do
        git clone ${httpRepo}
    done
}


function isThisDirectory() {
    local currentDirectoryTemp=$1
    return "${currentDirectoryTemp}" == "./" || "${currentDirectoryTemp}" == "."
}

function isGitDirOrThisDirOrParentDir() {
    local currentElementTemp=$1
    local currentRepoDirectoryTemp=$2

    return "${currentElementTemp}" == "./.git" || \
     isThisDirectory ${currentElementTemp} || \
     "${currentElementTemp}" == "${currentRepoDirectoryTemp}"
}

function moveEachElementToNewDirectory() {
    local currentRepoDirectoryTemp=$1

    for currentElement in `find . -maxdepth 1` ; do
		if isGitDirOrThisDirOrParentDir ${currentElement} ${currentRepoDirectoryTemp}; then
			continue
		fi
		mv -f ${currentElement}${currentDirectory}
    done
}

function moveEachRepositoryDirContentToNewDirectory() {
    for currentRepoDirectory in `find . -type d -maxdepth 1` ; do
        if isThisDirectory ${currentRepoDirectory} ; then
                continue
        fi

        mkdir ${currentRepoDirectory}/${currentRepoDirectory}
        cd ${currentRepoDirectory}

        moveEachElementToNewDirectory ${currentRepoDirectory}

        git add -A
        git commit -m "Moving dirs and files to new dir"${currentRepoDirectory}

        cd ../
    done
}


function isAnotherDirNotMainDir() {
    local mainRepoDirectoryTemp=$1
    local anotherRepoDirectoryTemp=$2

    return ! ${mainRepoDirectoryTemp} == ${anotherRepoDirectoryTemp}
}

function mergeMainRepoWithAnotherRepo() {
    local mainRepoDirectoryTemp=$1
    local anotherRepoDirectoryTemp=$2

    cd ${mainRepoDirectoryTemp}

    git remote add ${anotherRepoDirectoryTemp}~/test_merge_repo/${anotherRepoDirectoryTemp}
    git fetch ${anotherRepoDirectoryTemp}--tags
    git merge --allow-unrelated-histories ${anotherRepoDirectoryTemp}/master # or whichever branch you want to merge
    git remote remove ${anotherRepoDirectoryTemp}

    cd ../
}

function mergeAllRepositoriesToMainRepository() {
    local mainRepoDirectoryTemp=$1

    for anotherRepoDirectory in `find . -type d -maxdepth 1` ; do
	    if isAnotherDirNotMainDir ${mainRepoDirectoryTemp} ${anotherRepoDirectory}; then
		continue
	    fi
	    mergeMainRepoWithAnotherRepo ${mainRepoDirectoryTemp} ${anotherRepoDirectory}
    done
}

mainDirectory=$(echo $PWD)

cloneAllRepositories $@

moveEachRepositoryDirContentToNewDirectory


mainRepoDirectory=$(ls | sort -n | sed -n 1p)
echo "Repository that all other will be merged to: ${mainRepoDirectory}"

anotherDirectory=$(ls | sort -n | sed -n 2p)


echo "first: ${mainRepoDirectory}"

mergeMainRepoWithAnotherRepo ${mainRepoDirectory} ${anotherDirectory}


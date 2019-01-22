#!/usr/bin/env bash

declare -r mainDirectory=$(echo $PWD)


function cloneAllRepositories() {
    for httpRepo in "$@" ; do
        git clone ${httpRepo}
        echo ""
    done
}

function isThisDirectory() {
    local currentDirectory=$1;

    [[ "${currentDirectory}" = "." ]] || \
    [[ "${currentDirectory}" = "./" ]]
}

function isGitDir_orThisDir_orSecondDir_orSecondDirWithDot() {
    local firstDirectory=$1
    local secondDirectory=$2

    local secondDirectoryWithDot="./"$secondDirectory

    [[ "${firstDirectory}" = "./.git" ]] || \
    isThisDirectory ${firstDirectory}  || \
    [[ "${firstDirectory}" = "${secondDirectory}" ]] || \
    [[ "${firstDirectory}" = "${secondDirectoryWithDot}" ]]
}


function moveEachElementToNewDirectory() {
    local currentRepoDirectory=$1

    for currentElement in `find . -maxdepth 1` ; do
		if isGitDir_orThisDir_orSecondDir_orSecondDirWithDot ${currentElement} ${currentRepoDirectory}; then
		    echo "Skipped element: "${currentElement}
			continue
		fi

		mv -f ${currentElement} ${currentRepoDirectory}
    done
}

function moveEachRepositoryDirContentToNewDirectory() {
    for currentRepoDirectory in `find . -type d -maxdepth 1` ; do
        if isThisDirectory ${currentRepoDirectory} ; then
            continue
        fi

        mkdir ${currentRepoDirectory}/${currentRepoDirectory}
        cd ${mainDirectory}/${currentRepoDirectory}

        printf "\n|----------|\n"
        moveEachElementToNewDirectory ${currentRepoDirectory}
        printf "|----------|\n"

        git add -A
        git commit -m "Moving dirs and files to new dir"${currentRepoDirectory}

        cd ..

        printf "\n|----------|\n"
        echo "Current directory, after ..: "$(echo $PWD)
        printf "|----------|\n"
    done
}

function mergeMainRepoWithAnotherRepo() {
    local mainRepoDirectory=$1
    local anotherRepoDirectory=$2

    local anotherRepoDirectoryFullPath=${mainDirectory}/${anotherRepoDirectory}

    cd ${mainRepoDirectory}

    git remote add ${anotherRepoDirectory} ${anotherRepoDirectoryFullPath}
    git fetch ${anotherRepoDirectory} --tags
    git merge --allow-unrelated-histories ${anotherRepoDirectory}/master # or whichever branch you want to merge
    git remote remove ${anotherRepoDirectory}

    cd ..
}

function mergeAllRepositoriesToMainRepository() {
    local mainRepoDirectory=$1

    for anotherRepoDirectory in `find . -type d -maxdepth 1` ; do
        local prefix="./"
        local anotherRepoDirectoryWithoutDot=${anotherRepoDirectory/#$prefix}

	    if isGitDir_orThisDir_orSecondDir_orSecondDirWithDot ${anotherRepoDirectoryWithoutDot} ${mainRepoDirectory}; then
		    continue
	    fi

	    printf "\n|----------|\n"
	    echo "Will attempt merge repository:" ${anotherRepoDirectoryWithoutDot} " to main repository: " ${mainRepoDirectory}
        printf "|----------|\n"

	    mergeMainRepoWithAnotherRepo ${mainRepoDirectory} ${anotherRepoDirectoryWithoutDot}
    done
}

function mergeRepositories() {
    local httpRepositories=$@

    cloneAllRepositories ${httpRepositories}

    moveEachRepositoryDirContentToNewDirectory


    mainRepoDirectory=$(ls | sort -n | sed -n 1p)

    printf "\n|----------|\n"
    echo "Repository that all other will be merged to: ${mainRepoDirectory}"
    printf "|----------|\n"

    mergeAllRepositoriesToMainRepository ${mainRepoDirectory}
}

mergeRepositories $@

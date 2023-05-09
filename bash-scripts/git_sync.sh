#!/bin/bash
# This script is used to sync GitLab after Github -- Since this is payed for

# Static Variables:
sync_home="$HOME/apps/sync"
gitlab_home="${sync_home}/gitlab"
github_home="${sync_home}/github"
git_home="/usr/bin/git"
git_add="${git_home} add ."
git_push="${git_home} push origin master"
git_last_comment="${git_home} log -1 --pretty=%B"

# Repo Definition:
# Update these with the required repos you want to sync
repo_one="repo_name"
repo_two="repo_name"
repo_three="repo_name"

function sync_gitlab_after_github {
    cd ${github_home}/${repo_main} && ${git_home} pull && last_comment=$(${git_last_comment}) 
#    git_commit="${git_home} commit -m "`${last_comment}`"
    github_update_check=$(diff -rq ${github_home}/${repo_main} ${gitlab_home}/${repo_main} | grep 'github' | grep -vi '.git/' | grep -vi '.git:' | grep -vi '.gitignore' | grep -vi 'COMMIT_EDITMSG' | wc -l)
    gitlab_extra_file_check=$(diff -rq ${gitlab_home}/${repo_main} ${github_home}/${repo_main} | grep gitlab | grep -vi '.git/' | grep -vi '.git:' | grep -vi '.gitignore' | grep -vi 'COMMIT_EDITMSG' | wc -l)
    gitlab_diff_check=$(diff -rq ${github_home}/${repo_main} ${gitlab_home}/${repo_main} |  grep gitlab | grep -vi '.git/' | grep -vi '.git:' | grep -vi '.gitignore' | grep -vi 'COMMIT_EDITMSG' | awk '{print $4}')

    if [ ${github_update_check} -ne 0 ]; then
        cp -R ${github_home}/${repo_main}/* ${gitlab_home}/${repo_main}
        cd ${gitlab_home}/${repo_main} && ${git_add} && ${git_home} commit -m "${last_comment}" && ${git_push}
    else
        echo "No updates in Repository ${repo_main}. Moving on..."
    fi

    if [ ${gitlab_extra_file_check} -ne 0 ]; then
        find ${gitlab_home} -name ${gitlab_diff_check} -exec rm -rf {} \;
        cd ${gitlab_home}/${repo_main} && ${git_add} && ${git_home} commit -m "${last_comment}" && ${git_push}
    else
        echo "No extra files in Repository ${repo_main}. Moving on..."
    fi
}

function check_repo_func {
    if [ -d ${gitlab_home}/${repo_one} ]; then
        repo_main=${repo_one}
        sync_gitlab_after_github
    else
        echo "${repo_main} folder does not exist in ${gitlab_home}"
        echo "Please sync the repos by copying them on the server and adjusting the script"
    fi

    if [ -d ${gitlab_home}/${repo_two} ]; then
        repo_main=${repo_two}
        sync_gitlab_after_github
    else
        echo "${repo_main} folder does not exist in ${gitlab_home}"
        echo "Please sync the repos by copying them on the server and adjusting the script"
    fi

    if [ -d ${gitlab_home}/${repo_three} ]; then
        repo_main=${repo_three}
        sync_gitlab_after_github
    else
        echo "${repo_main} folder does not exist in ${gitlab_home}"
        echo "Please sync the repos by copying them on the server and adjusting the script"
    fi
}

check_repo_func

# This function is for instant sync but it can have some issues since it is creating a lot of pull requests
# Good for testing but to avoid issues, it's better not to generate requests every second
#function sync_instant {
#    i=0
#    until [ $i -eq 60 ]; do
#        check_repo_func
#        ((i=i+1))
#    done
#}
#sync_instant
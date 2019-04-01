#!/usr/bin/env bash

# This script will deploy the application into google app engine. User confirmation,
# and credentials input may be requested

# This script assumes a repo structure like this:
# repo_name
# |
# | -- python_package
#      | -- __init__.py
#      | -- some_file.py
#      | -- ...

# You must have git installed
# You must have the ssh keys for bitbucket
# You must have the google sdk properly set up

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
MAIN_REPO_DIR=$( dirname $SCRIPT_DIR )

# It is supposed your are going to use always the same cloud provider and the same
# team/organization name inside the cloud provider
GIT_CLOUD="BITBUCKET"
YOUR_ORG_NAME="pedro-iatzky"

if [ $GIT_CLOUD == "BITBUCKET" ]; then
    CLOUD_HTTPS="https://bitbucket.org"
    CLOUD_SSH="git@bitbucket.org"
else
    CLOUD_HTTPS="https://github.com"
    CLOUD_SSH="git@github.com"
fi

usage() {
    echo "usage: deploy_on_gae [[ output_dir ] [ -pm python_module ] | [-h help]]"
    }


assign_out_dir() {
    # Assign the Output directory, just if it wasn't assigned yet
    if [ -z "$OUT_DIR" ]; then
        OUT_DIR=$1/"${MAIN_REPO_DIR##*/}"_deploy
    fi
}


while [ "$1" != "" ]; do
    case $1 in
        -pm | --python_module )    shift
                                   MAIN_PYTHON_MODULE=$1
                                   ;;
        -https | --use_https  )    shift
                                   USE_HTTPS=true
                                   ;;
        -h | --help )              usage
                                   exit
                                   ;;
        * )                        assign_out_dir $1
    esac
    shift
done




set_up_dir() {
    # Set up the folder structures
    # We abuse from the fact that bash variables are set as global

    if [ -z "$OUT_DIR" ]; then
        assign_out_dir "$(pwd)"
    fi

    if [ ! -d "$OUT_DIR" ]; then
        mkdir "$OUT_DIR"
    fi

    DEPLOYMENT_DIR="$OUT_DIR"/"deploy"
    TMP_DIR="$OUT_DIR"/"tmp"

    if [ ! -d "$DEPLOYMENT_DIR" ]; then
        mkdir "$DEPLOYMENT_DIR"
    fi

    if [ ! -d "$TMP_DIR" ]; then
        mkdir "$TMP_DIR"
    fi


    if [ -z "$MAIN_PYTHON_MODULE" ]; then
    # If no main python module is specified, the one with the repo name is going
    #  to be searched for
        MAIN_PYTHON_MODULE="${MAIN_REPO_DIR##*/}"
    fi

}


download_and_install_dependencies() {
    # fp_requirements.txt have the internal dependencies
    while read line; do
        REMOTE_REPO=$(echo $line | awk $'{print($1)}')
        COMMIT=$(echo $line | awk $'{print($2)}')
        PYTHON_PACKAGE=$(echo $line | awk $'{print($3)}')
        if [ ! -z $REMOTE_REPO ]; then
            echo $REMOTE_REPO
        # Clone the remote repository
        if [ $USE_HTTPS ]; then
            git clone "$CLOUD_HTTPS"/"$YOUR_ORG_NAME"/"$REMOTE_REPO".git "$TMP_DIR"/"$REMOTE_REPO"
        else
            git clone "$CLOUD_SSH":"$YOUR_ORG_NAME"/"$REMOTE_REPO".git "$TMP_DIR"/"$REMOTE_REPO"
        fi

        # Checkout the specified version/commit
        $( cd "$TMP_DIR"/"$REMOTE_REPO" >/dev/null 2>&1 && $(git checkout $COMMIT) )
        # Copy the python package into the deployment folder
        $( cp -r "$TMP_DIR"/"$REMOTE_REPO"/"$PYTHON_PACKAGE" "$DEPLOYMENT_DIR" )
        fi
    done < "$SCRIPT_DIR"/fp_requirements.txt
}


move_repo_files() {
    # copy dockerfile, gae app.yaml, requirements.txt and other useful files
    for file in $(ls $SCRIPT_DIR); do
        if [[ $file != "fp_requirements.txt" && $file != "deployment_steps.md" && \
              $file != "deploy_on_gae.sh" ]]; then
            cp "$SCRIPT_DIR"/"$file" "$DEPLOYMENT_DIR"
        fi
    done

    # copy the main app python module
    cp -r "$MAIN_REPO_DIR"/"$MAIN_PYTHON_MODULE" "$DEPLOYMENT_DIR"
}


deploy_onto_gae() {
    $( cd "$DEPLOYMENT_DIR" >/dev/null 2>&1 && \
    gcloud app deploy --promote --stop-previous-version)

}


main() {
    # TODO check the needed tools are installed

    echo "seting the directory up..."
    set_up_dir
    echo "downloading and installing dependencies"
    download_and_install_dependencies
    echo "moving main repository files"
    move_repo_files
    deploy_onto_gae
}


main

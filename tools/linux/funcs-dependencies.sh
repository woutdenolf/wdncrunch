#!/bin/bash
# 
# Install project dependencies (system and pypi).
# 

SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${SCRIPT_ROOT}/funcs.sh
source ${SCRIPT_ROOT}/funcs-python.sh

function install_system_dependencies()
{
    cprintstart
    cprint "Installing system requirements ..."

    if [[ $(dryrun) == false ]]; then
        require_web_access

        pip_install numpy
    fi
}


function install_system_dependencies_dev()
{
    cprintstart
    cprint "Installing system requirements (dev) ..."

    if [[ $(dryrun) == false ]]; then
        require_web_access

        mapt-get install pandoc # nbsphinx
    fi
}

function install_nopypi_dependencies()
{
    return
}

function install_pypi_dependencies()
{
    cprintstart
    cprint "Installing pypi requirements ..."
    if [[ $(dryrun) == false ]]; then
        require_web_access
        pip_install -r $(project_folder)/requirements.txt
    fi
}


function install_pypi_dependencies_dev()
{
    cprintstart
    cprint "Installing pypi requirements (dev) ..."
    if [[ $(dryrun) == false ]]; then
        require_web_access
        pip_install -r $(project_folder)/requirements-dev.txt
    fi
}


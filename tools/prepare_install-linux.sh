#!/bin/bash
# 
# This script will install all wdncrunch Python 2 and 3 dependencies.
# 

# ============Usage============
show_help()
{
  echo "
        Usage: prepare_installation  [-v version] [-y] [-t] [-d]

        -v version      Python version to be used (2, 3, 2.7, 3.5, ...).
        -y              Answer yes to everything.
        -t              Time limited build.
        -d              Dry run.
        -u              Install for user only.

        For Example: ./prepare_installation -v 3 -d

        -h              Help
       "
}

# ============Initialize environment============
SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_ROOT/funcs.sh
resetEnv

# ============Adapt environment based on script arguments============
OPTIND=0
while getopts "v:uythd" opt; do
  case $opt in
    h)
      show_help
      cd $RESTORE_WD
      return $RETURNCODE_ARG
      ;;
    y)
      FORCECHOICE="y"
      ;;
    t)
      TIMELIMITED=true
      ;;
    u)
      INSTALL_SYSTEMWIDE=false
      ;;
    d)
      NOTDRY=false
      ;;
    \?)
      echo "Invalid option: -$OPTARG. Use -h flag for help." >&2
      cd $RESTORE_WD
      return $RETURNCODE_ARG
      ;;
  esac
done
initEnv

# ============Initialize Python============
initPython
Retval=$?
if [ $Retval -ne 0 ]; then
    cd $RESTORE_WD
    return $Retval
fi

mkdir -p ${PYTHONV}
cd ${PYTHONV}
INSTALL_WD=$(pwd)

# ============Initialize Pip============
initPip
Retval=$?
if [ $Retval -ne 0 ]; then
    cd $RESTORE_WD
    return $Retval
fi

# ============Show information and ask to proceed============
# /usr/lib/python2.7/dist-packages: system-wide, installed with package manager
# /usr/local/lib/python2.7/dist-packages: system-wide, installed with pip
#
# /usr/lib/python2.7/site-packages:
# /usr/local/lib/python2.7/site-packages:
#
# /usr/lib/python2.7:
# /usr/lib/pymodules/python2.7:
#
# ~/.local/lib/python2.7/site-packages: user-only, installed with pip --user
#
# <virtualenv_name>/lib/python2.7/site-packages: virtual environment, installed with pip

cprint "Python version: $PYTHONFULLV"
cprint "Python location: $PYTHON_EXECUTABLE"
cprint "Python include: $PYTHON_INCLUDE_DIR"
cprint "Python library: $PYTHON_LIBRARY"
cprint "Pip:$($PIPBIN --version| awk '{$1= ""; print $0}')"
cprint "Root priviliges: $SYSTEM_PRIVILIGES"
cprint "System wide installation: $INSTALL_SYSTEMWIDE"

if [[ -z $FORCECHOICE ]]; then
    read -p "Approximately xGB of data will added to \"$(pwd)\". Continue (Y/n)?" CHOICE
else
    CHOICE=$FORCECHOICE
fi
case "$CHOICE" in 
  y|Y ) ;;
  n|N ) 
        cd $RESTORE_WD
        return $RETURNCODE_CANCEL;;
  * ) ;;
esac

# ============Install basics============
cprint "Install basics ..."
if [[ $NOTDRY == true && $SYSTEM_PRIVILIGES == true ]]; then
    mexec "apt-get -y install make build-essential git"
fi

BUILDSTEP=$(( $BUILDSTEP+1 ))
BUILDSTEPS=$(( $BUILDSTEPS+1 ))

# ============Install system dependencies============
cprint "Install python module dependencies ..."
if [[ $SYSTEM_PRIVILIGES == true ]]; then
    if [[ $NOTDRY == true ]]; then
        mexec "apt-get -y ...."
    fi
    BUILDSTEP=$(( $BUILDSTEP+1 ))
    BUILDSTEPS=$(( $BUILDSTEPS+1 ))
fi


# ============Install modules============
cprint "Install python modules available on pypi..."
if [[ $NOTDRY == true ]]; then
    $PIPBIN install --upgrade setuptools
    $PIPBIN install --upgrade wheel

    $PIPBIN install --upgrade -r $SCRIPT_ROOT/../requirements.txt
fi

BUILDSTEP=$(( $BUILDSTEP+1 ))
BUILDSTEPS=$(( $BUILDSTEPS+1 ))

# ============Custom installation============
cprint "Install python modules not available on pypi..."

# ============Cleanup============
cprint "Cleaning up ..."
cd $RESTORE_WD

if [[ $NOTDRY == true ]]; then
    if [[ $SYSTEM_PRIVILIGES == true ]]; then
        mexec "apt-get -y autoremove"
    else
        cprint "Variables have been added to $WDNCRUNCHRC."
    fi

    if [[ $TIMELEFT == true ]]; then
        cprint "All done ($BUILDSTEP/$BUILDSTEPS)! You should now be able to install wdncrunch."
    else
        cprint "Not everything has been build due to time restrictions. Run the script again ($BUILDSTEP/$BUILDSTEPS)."
    fi
else
    cprint "Dry build $BUILDSTEP/$BUILDSTEPS."
fi

ELAPSED_TIME=$(($SECONDS - $START_TIME))
cprint "Total execution time = $(( $ELAPSED_TIME/60 )) min"


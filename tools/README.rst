Guide for developers
====================

1. `Configure your local git.  <localrefconfiggit_>`_

2. `Contribute.  <localrefcontribute_>`_

3. `Check whether a branch can be released. <localrefreleasable_>`_

4. `Increase the version number.  <localrefincversion_>`_

5. `Release and deploy. <localrefreleaseversion_>`_

6. `Start a project. <localrefstart_>`_


.. _localrefconfiggit:

Configure git
-------------

.. code-block:: bash

    git config --global user.name githubname
    git config --global user.email user@domain
    git config --global user.signingkey YOURMASTERKEYID

The signing key is only needed by project managers to sign tags and PyPi releases (see `signing  <localrefsigning_>`_). Other contributors only need to concern themselves with pull-requests on Github (see `contribute  <localrefcontribute_>`_).


.. _localrefcontribute:

Contribute
----------

Assuming you forked the project on Github, then your fork will be referred to as "origin" and the repository you forked from will be referred to as "upstream".

* Clone your fork locally:

.. code-block:: bash

  export PROJECT=wdncrunch (or any other project name)
  git clone https://github.com/forkuser/${PROJECT}
  git remote add upstream https://github.com/woutdenolf/${PROJECT}

* Add a feature:

.. code-block:: bash

  # Branch of the upstream master
  git fetch upstream
  git checkout upstream/master
  git branch feat-something
  git checkout feat-something

  # Stay up to date with upstream
  git branch --set-upstream-to=upstream/master
  git pull

  # Commit changes ...
  git commit -m "..."

  # Push to origin
  git push origin feat-something

* Create a new pull request with

  base fork: woutdenolf/${PROJECT} (upstream)

  base: master

  head fork: forkuser/${PROJECT} (origin)

  compare: feat-something

* Keep your master up to date:

.. code-block:: bash
  
  git checkout master
  git pull upstream master (== git fetch upstream; git merge upstream/master)
  git push origin master

* Clean up your repository:

.. code-block:: bash
  
  git fetch -p upstream


.. _localrefincversion:

Increase the version
--------------------

1. Get the master

.. code-block:: bash
  
  git checkout master
  git pull upstream master

2. Update version in _version.py and update CHANGELOG.rst (see `versioning  <localrefversion_>`_)

.. code-block:: bash
  
  echo `python -c "from _version import version;print(\"v{}\".format(version));"`

3. Check whether the branch can be `released  <localrefreleasable_>`_.

4. Commit and tag new version

.. code-block:: bash
  
  git add .
  git commit -m "Bump version to 1.2.3"
  git tag -s v1.2.3 -m "Version 1.2.3"
  git push origin
  git push origin v1.2.3

5. Create a new pull request with

   base fork: woutdenolf/${PROJECT} (upstream)

   base: master

   head fork: forkuser/${PROJECT} (origin)

   compare: v1.2.3


.. _localrefreleaseversion:

Release and deploy
------------------

1. Get the version to be released

.. code-block:: bash
  
  git checkout master
  git pull upstream master
  git checkout v1.2.3

2. Check whether the branch can be `released  <localrefreleasable_>`_. `Increase the version number <localrefincversion_>`_ when something needed fixing.

3. Create a release on Github based on the tag

  Title: Release of version MAJOR.MINOR.MICRO

  Body: Copy from CHANGELOG

4. Deploy code (see `pypi setup  <localrefdeployment_>`_)

.. code-block:: bash

  twine upload -r pypitest --sign ${RELEASEDIR}/*
  twine upload -r pypi --sign ${RELEASEDIR}/*

5. Deploy documentation

.. code-block:: bash

  https://testpypi.python.org/pypi?%3Aaction=pkg_edit&name=${PROJECT}
  http://pypi.python.org/pypi?%3Aaction=pkg_edit&name=${PROJECT}


.. _localrefreleasable:

Check branch releasable
-----------------------

1. Create a clean `sandbox <localrefsandbox_>`_ and make a fresh git clone

2. Release directory

.. code-block:: bash
  
  export RELEASEDIR=...
  export VERSION=`python -c "from _version import strictversion as version;print(\"{}\".format(version));"`
  rm -r ${RELEASEDIR}
  mkdir -p ${RELEASEDIR}/dist

3. Build the source tarball

.. code-block:: bash
  
  python setup.py clean sdist
  cp dist/${PROJECT}-${VERSION}.tar.gz ${RELEASEDIR}/dist

4. Test the source

.. code-block:: bash
  
  tar zxvf ${RELEASEDIR}/dist/${PROJECT}-${VERSION}.tar.gz
  cd ${PROJECT}-${VERSION}
  pip install .
  python -m ${PROJECT}.tests.test_all
  
5. Release the docs

.. code-block:: bash
  
  pip install sphinx
  python setup.py clean build_doc
  pip uninstall -y ${PROJECT}
  cd build/sphinx/html
  zip -r ${RELEASEDIR}/html_doc.zip .
  cd ../../..

6. Inspect the docs

.. code-block:: bash
  
  firefox build/sphinx/html/index.html

7. Build the wheels (do this on different platforms)

.. code-block:: bash
  
  python setup.py clean bdist_wheel --universal
  cp dist/${PROJECT}-${VERSION}-py2.py3-none-any.whl ${RELEASEDIR}/dist

8. Test the wheels

.. code-block:: bash
  
  pip install ${RELEASEDIR}/dist/${PROJECT}-${VERSION}-py2.py3-none-any.whl
  python -m ${PROJECT}.tests.test_all
  pip uninstall -y ${PROJECT}

9. Delete the `sandbox  <localrefsandbox_>`_


.. _localrefdeployment:

Deployment
----------

Add PyPi credentials file ~/.pypirc (chmod 600):

.. code-block:: bash

  [distutils]
  index-servers =
    pypi
    pypitest

  [pypi]
  repository=https://pypi.python.org/pypi
  username=...
  password=...

  [pypitest]
  repository=https://testpypi.python.org/pypi
  username=...
  password=...

Register project (already done):

.. code-block:: bash

  twine register -r pypi dist/*.whl
  twine register -r pypitest dist/*.whl


.. _localrefsandbox:

Sandbox
-------

* Using `virtualenv <https://virtualenv.pypa.io/>`_

.. code-block:: bash

  virtualenv test1.2.3
  cd test1.2.3
  source bin/activate

* Using `pyenv <https://github.com/pyenv/pyenv/>`_

Installation and activation

.. code-block:: bash

  export PYTHON_CONFIGURE_OPTS="--enable-shared"
  export PYENV_ROOT="~/.pyenv"
  if [[ ! -d $PYENV_ROOT ]]; then
    git clone https://github.com/pyenv/pyenv.git ${PYENV_ROOT}
    git clone https://github.com/pyenv/pyenv-virtualenv.git ${PYENV_ROOT}/plugins/pyenv-virtualenv
  fi
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"

Manage python versions

.. code-block:: bash

  pyenv install 2.7.13
  pyenv uninstall 2.7.13

  pyenv local 2.7.13 (in this directory)
  pyenv shell 2.7.13 (in this shell)
  pyenv shell --unset

  pyenv version
  pyenv versions

Manage virtualenvs

.. code-block:: bash

  pyenv virtualenv 2.7.13 myenvname
  pyenv activate myenvname
  pyenv deactivate
  pyenv uninstall myenvname
  pyenv virtualenvs


.. _localrefversion:

Versioning
----------

`Semantic versioning <http://semver.org/>`_ is followed::

  MAJOR.MINOR.MICRO.SERIAL

  SERIAL: bump when changes not to the code
  MICRO : bump when bug fix is done
               when bumping SERIAL == 15
  MINOR : bump when API changes backwards compatible
               when new functionality is added
               when bumping MICRO == 15
  MAJOR : bump when API changes not backwards compatible
 
  Always reset the lower numbers to 0.

  dev   : not tested
  alpha : begin testing
  beta  : feature complete
  rc    : test complete
  final : stable version


Install external dependencies
-----------------------------

.. code-block:: bash

    . ${PROJECT}/tools/prepare_install-linux.sh [-v 3]
    if [[ $? == 0 ]]; then echo "OK"; else echo "NOT OK"; fi


Help
----

.. code-block:: bash

    python setup.py --help-commands
    python setup.py sdist --help-formats
    python setup.py bdist --help-formats


.. _localrefsigning:

Signing
-------

Generate PGP keypair:

.. code-block:: bash

    while true; do ls -R / &>/dev/null; sleep 1; done &
    gpg --gen-key

Generate a revocation certificate:

.. code-block:: bash

    gpg --output revoke.asc --gen-revoke YOURMASTERKEYID
    shred --remove revoke.asc

Publish public key:

.. code-block:: bash

    gpg --keyserver pgp.mit.edu --send-keys YOURMASTERKEYID

Share public key:

.. code-block:: bash

    gpg --armor --export YOURMASTERKEYID
    (or look it up in pgp.mit.edu)

Revoke PGP key:

.. code-block:: bash

    gpg --keyserver pgp.mit.edu --recv-keys YOURMASTERKEYID
    gpg --import revoke.asc
    gpg --keyserver pgp.mit.edu --send-keys YOURMASTERKEYID

Share private PGP key:

.. code-block:: bash

    gpg --export-secret-key -a | ssh user@host gpg --import -

Show all keys:

.. code-block:: bash

    gpg --list-keys


.. _localrefstart:

Start a project
---------------

1. Create an empty project on github and clone it locally

.. code-block:: bash

    git clone https://github.com/user/${PROJECT}

2. Copy the wdncrunch template and adapt the following

.. code-block:: bash

    export PROJECT=...
    rsync -av wdncrunch/ ${PROJECT}/ --exclude .git --exclude ci/README.rst --exclude tools/README.rst
    cd ${PROJECT}/
    mv wdncrunch ${PROJECT}
    
    setup.py: replace project name and description
    README.rst: replace project name (not in the guidelines link)
    doc: replace project name

3. Initialize the documentation when you want to start from scratch:

.. code-block:: bash

    sphinx-quickstart
    sphinx-apidoc -o doc/source/modules ${PROJECT}

4. `Check whether the project can be released <localrefreleasable_>`_

5. Create genesis version

.. code-block:: bash

    git add .
    git commit -m "Start from wdncrunch template"
    git tag -s genesis 21ee8fa -m "Unreleased genesis version"
    git push origin master:master
    git push origin genesis

6. Github configuration
    * Add description
    * Add license
    * Register with CI services




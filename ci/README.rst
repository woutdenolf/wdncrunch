Guide for continuous integration
================================

1. `Travis CI <localreftravis_>`_ (linux)

2. `AppVeyor <localrefappveyor_>`_ (windows)


.. _localreftravis:

Travis CI
---------

Pre-build dependencies
++++++++++++++++++++++

1. Install Ubuntu release used by Travis (http://releases.ubuntu.com/) and make sure you have a "travis" user:

.. code-block:: bash

  adduser travis
  usermod -aG sudo travis

2. Install Python release used by Travis:

.. code-block:: bash

  sudo -s
  apt-get update
  apt-get install libbz2-dev libsqlite3-dev libreadline-dev zlib1g-dev libncurses5-dev libssl-dev libgdbm-dev libssl-dev openssl tk-dev

  pyversion=2.7.14
  wget https://www.python.org/ftp/python/${pyversion}/Python-${pyversion}.tgz
  tar -xvzf Python-${pyversion}.tgz
  rm Python-${pyversion}.tgz
  cd Python-${pyversion}

  ./configure --prefix=/opt/python/${pyversion} --enable-shared LDFLAGS=-Wl,-rpath=/opt/python/${pyversion}/lib --enable-optimizations
  make -j2
  make install

  cd ..
  rm -rf Python-${pyversion}

  export PATH="/opt/python/${pyversion}/bin/:$PATH"

3. Install pip:

.. code-block:: bash

  python -m ensurepip
  pip install --upgrade pip
  pip install virtualenv

4. Create virtual env:

.. code-block:: bash

  cd /home/travis
  virtualenv python${pyversion}
  source python${pyversion}/bin/activate

5. Install dependencies:

.. code-block:: bash

  apt-get install git
  export PROJECT=wdncrunch (or any other project name)
  git clone https://github.com/woutdenolf/${PROJECT}.git
  sudo -s   # because we need to install system packages
  . ${PROJECT}/tools/prepare_install-linux.sh -u

Accept when:

.. code-block:: bash

  Python version: 2.7.13 
  Python location: /home/travis/virtualenv/python2.7.13/bin/python 
  Python include: /opt/python/2.7.13/include/python2.7 
  Python library: /opt/python/2.7.13/lib/libpython2.7.so 
  Pip: 9.0.1 from /home/travis/virtualenv/python2.7.13/lib/python2.7/site-packages (python 2.7) 
  Root priviliges: true 
  System wide installation: false 
  
6. Create pre-build and upload:

.. code-block:: bash

  tar -czf ${PROJECT}.travis.python2.7.tgz 2.7/lib1 2.7/lib2 ...
  curl --upload-file ${PROJECT}.travis.python2.7.tgz https://transfer.sh/${PROJECT}.travis.python2.7.tgz

.. _localrefappveyor:

AppVeyor
--------

1. AppVeyor project settings:
    custom configuration file name: ci/appveyor.yml
    build version: {build}





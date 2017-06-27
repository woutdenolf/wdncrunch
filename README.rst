wdncrunch: example library for python
=====================================

Getting started
---------------

Install dependencies:

.. code-block:: bash

    git clone https://github.com/woutdenolf/wdncrunch
    . wdncrunch/tools/prepare_install-linux.sh

Install from PyPi:

.. code-block:: bash

    pip install wdncrunch [--user]

Install from source:

.. code-block:: bash

    git clone https://github.com/woutdenolf/wdncrunch
    cd wdncrunch
    pip install [--user] .

Test:

.. code-block:: bash

    python -m wdncrunch.tests.test_all

Documentation:

http://pythonhosted.org/wdncrunch


Developers
----------

|Travis Status Master| |Appveyor Status Master|

Main development website: https://github.com/woutdenolf/wdncrunch

Distribution website: https://pypi.python.org/pypi/wdncrunch

Guidelines for contributors and project managers can be found in the `developers guide <https://github.com/woutdenolf/wdncrunch/blob/master/tools/README.rst/>`_.


Use without installation
------------------------

.. code-block:: bash

    git clone https://github.com/woutdenolf/wdncrunch
    cd wdncrunch

To import modules from a package without installing the package, add the 
directory of the package to the PYTHONPATH environment variable or add this
to the top of your script

.. code-block::

    import sys
    sys.path.insert(1,'/data/id21/inhouse/wout/dev/wdncrunch')


Import as follows:

.. code-block:: 

    from wdncrunch.modulea.classa import classa


.. |Travis Status Master| image:: https://travis-ci.org/woutdenolf/wdncrunch.svg?branch=master
   :target: https://travis-ci.org/woutdenolf/wdncrunch
.. |Appveyor Status Master| image:: https://ci.appveyor.com/api/projects/status/github/woutdenolf/wdncrunch?svg=true&branch=master
   :target: https://ci.appveyor.com/project/woutdenolf/wdncrunch/branch/master

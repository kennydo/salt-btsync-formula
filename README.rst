btsync
======
Installs the ``btsync`` package from the `YeaSoft repo`_ and (optionally) creates ``btsync`` instance configuration files based on pillar data.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``btsync``
-----------

Adds the `YeaSoft repo`_ and installs the ``btsync`` package.

This state also deletes the default configuration file ``/etc/btsync/debconf-default.conf``, so if you manually make a configuration file, name it something other than ``debconf-default.conf``.

``btsync.config``
------------------

Includes the ``btsync`` state.

Use this state to make the ``/etc/btsync`` directory of btsync instance configurations entirely managed by salt. Beware that this will delete all of the files in that directory that aren't managed by salt.

This state creates an instance configuration file for each instance you specify in pillar. See below under Configuration for details.

Configuration
=============

Each instance has 2 different things to configure: the daemon and the the btsync instance. On the `YeaSoft repo`_ page, you can see under "Usage Notes" that the daemon is configured using comments in the json file that also stores the btsync configuration. This formula handles the actual creation of that file, so you don't have to worry about that.

For each instance you define in ``pillar['btsync_instances']``, you can define a dictionary under the ``daemon`` key and specify the values for ``DAEMON_UID``, ``DAEMON_GID``, ``DAEMON_UMASK``, etc. These parameters specify how you want each btsync instance to be run. For example, you can have one instance of btsync be run as root, but have another instance be run as a different user.

Next, you define a dictionary under the ``config`` key for each instance. This dictionary is the part that the btsync program cares about. The ``pillar.example`` shows sample pillar configurations you might use.

.. important:: Disable ``check_for_updates``

   The `YeaSoft repo`_ handles updates for the ``btsync`` package, so the daemon will not run unless ``check_for_updates`` is disabled for each instance.
    

.. _YeaSoft repo: http://www.yeasoft.com/site/projects:btsync-deb:btsync-server

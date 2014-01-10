#!py
import json


def __get_merged_repo_parameters():
    return __salt__['grains.filter_by']({
        'Debian': {
            'apt_base_uri': 'http://debian.yeasoft.net/btsync',
            'keyserver': 'keys.gnupg.net',
            'keyid': '6BF18B15'
        },
    }, merge=__salt__['pillar.get']('btsync:lookup'))


def run():
    """
    Adds the btsync repo, installs the btsync package, and creates the
    configuration for each instance.
    """
    ret = dict()

    ret['yeasoft_repo'] = __add_btsync_repo()
    ret['btsync'] = __install_btsync_package()
    ret['btsync-debconf.conf'] = __remove_default_instance()

    instances = __pillar__.get('btsync_instances')
    for index, instance in enumerate(instances):
        daemon = instance.get('daemon', {})
        btsync = instance.get('config', {})

        name = "/etc/btsync/instance_{0}.conf".format(index)
        daemon_config = "\n".join(
            "//{0}={1}".format(key, value) for key, value
            in instance.get('daemon', {}).iteritems())
        btsync_config = json.dumps(btsync)
        contents = "{0}\n{1}".format(daemon_config, btsync_config)

        ret[name] = {
            'file.managed': [{
                'name': name,
                'user': daemon.get('DAEMON_UID', 'root'),
                'group': daemon.get('DAEMON_GID', 'root'),
                'mode': 400,
                'contents': contents,
            }],
        }
    return ret


def __add_btsync_repo():
    """
    Adds the yeasoft btsync repo
    """
    repo = __get_merged_repo_parameters()

    dist = __grains__['lsb_distrib_codename']
    name = "deb {0} {1} main".format(repo['apt_base_uri'],
                                     dist)

    return {
        'pkgrepo.managed': [{
            'name': name,
            'dist': dist,
            'keyserver': repo['keyserver'],
            'keyid': repo['keyid'],
        }],
    }

def __install_btsync_package():
    """
    Installs the btsync package
    """
    return {
        'pkg.installed': [{
            'name': 'btsync',
        }],
    }


def __remove_default_instance():
    """
    Ensures that the default instance conf file (from the package) is absent.
    """
    return {
        'file.absent': [{
            'name': '/etc/btsync/debconf-default.conf',
            }],
    }


#!py


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

    return ret


def __add_btsync_repo():
    """Adds the yeasoft btsync repo"""
    repo = __get_merged_repo_parameters()

    dist = __grains__['lsb_distrib_codename']
    name = "deb {0} {1} main".format(repo['apt_base_uri'],
                                     dist)

    return {
        'pkgrepo': [
            'managed',
            {
                'name': name,
                'dist': dist,
                 'keyserver': repo['keyserver'],
                 'keyid': repo['keyid'],
             },
        ],
    }

def __install_btsync_package():
    """Installs the btsync package"""
    pass

def __remove_default_instance():
    """
    Ensures that the default instance conf file (from the package) is absent
    """
    pass

def __create_instance(instance):
    """Creates the config file for a single instance"""
    pass

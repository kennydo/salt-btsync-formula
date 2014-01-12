#!py
import json


def run():
    """
    Creates the configuration files for each btsync instance based on
    pillar.
    """
    ret = {'include': ['btsync']}

    instance_names = list()
    instances = __pillar__.get('btsync_instances', [])
    for index, instance in enumerate(instances):
        daemon = instance.get('daemon', {})
        btsync = instance.get('config', {})

        name = "/etc/btsync/instance_{0}.conf".format(index)
        instance_names.append(name)

        daemon_config = "\n".join(
            "//{0}={1}".format(key, value) for key, value
            in instance.get('daemon', {}).iteritems())
        # the daemon prefers the json to have nice spacing
        # when it asserts that check_for_updates is set to false,
        # so indent the json output to make it pretty print
        btsync_config = json.dumps(btsync,
                                   indent=4)
        contents = "{0}\n{1}".format(daemon_config, btsync_config)

        ret[name] = {
            'file.managed': [
                {'name': name},
                {'user': daemon.get('DAEMON_UID', 'root')},
                {'group': daemon.get('DAEMON_GID', 'root')},
                {'mode': 400},
                {'contents': contents},
                {'watch_in': [
                    {'service': 'btsync'}
                ]},
            ],
        }

    instances_directory_config = [
        {'name': '/etc/btsync'},
        {'user': 'root'},
        {'group': 'root'},
        {'mode': 755},
        {'clean': True},
        {'watch_in': [
            {'service': 'btsync'},
        ]},
    ]

    requirements = [{'pkg': 'btsync'}]
    for name in instance_names:
        requirements.append({'file': name})
    instances_directory_config.append({'require': requirements})

    ret['btsync_instances_directory'] = {
        'file.directory': instances_directory_config
    }

    return ret


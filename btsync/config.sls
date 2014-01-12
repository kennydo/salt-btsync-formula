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

    ret['btsync_instances_directory'] = {
        'file.directory': [
            {'name': '/etc/btsync'},
            {'clean': True},
            {'require': [{'file': name} for name in instance_names]},
            {'watch_in': [
                {'service': 'btsync'},
            ]},
        ],
    }

    return ret


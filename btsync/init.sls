{% from "btsync/map.jinja" import btsync with context %}

yeasoft_repo:
  pkgrepo.managed:
    - name: deb {{ btsync.apt_base_uri }} {{ grains['lsb_distrib_codename'] }} main
    - dist: {{ grains['lsb_distrib_codename'] }}
    - keyserver: {{ btsync.keyserver }}
    - keyid: {{ btsync.keyid }}
    - require_in:
      - pkg: btsync

btsync:
  pkg.installed

/etc/btsync/debconf-default.conf:
  file.absent

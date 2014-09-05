unique template datastores;

prefix "/software/components/opennebula";

"datastores" = list(
    nlist(
        "name", "ceph",
        "bridge_list", list("hyp004.cubone.os"),
        "ceph_host", list("ceph001.cubone.os","ceph002.cubone.os","ceph003.cubone.os"),
        "ceph_secret", "35b161e7-a3bc-440f-b007-cb98ac042646",
        "ceph_user", "libvirt",
        "datastore_capacity_check", true,
        "pool_name", "one",
        "type", "IMAGE_DS"
    ),
);
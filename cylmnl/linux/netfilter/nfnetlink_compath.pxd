# only NF_NETLINK_CONNTRACK_ constants

cdef extern from "linux/netfilter/nfnetlink_compat.h" nogil:
    # nfnetlink groups: Up to 32 maximum
    enum: NF_NETLINK_CONNTRACK_NEW
    enum: NF_NETLINK_CONNTRACK_UPDATE
    enum: NF_NETLINK_CONNTRACK_DESTROY
    enum: NF_NETLINK_CONNTRACK_EXP_NEW
    enum: NF_NETLINK_CONNTRACK_EXP_UPDATE
    enum: NF_NETLINK_CONNTRACK_EXP_DESTROY

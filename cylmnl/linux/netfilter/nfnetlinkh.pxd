from libc.stdint cimport uint8_t, uint16_t

cdef extern from "linux/types.h" nogil:
    ctypedef uint8_t  __u8
    ctypedef uint16_t __be16


cdef extern from "linux/netfilter/nfnetlink.h" nogil:
    enum NfnetlinkGroups "nfnetlink_groups":
        NFNLGRP_NONE
        NFNLGRP_CONNTRACK_NEW
        NFNLGRP_CONNTRACK_UPDATE
        NFNLGRP_CONNTRACK_DESTROY
        NFNLGRP_CONNTRACK_EXP_NEW
        NFNLGRP_CONNTRACK_EXP_UPDATE
        NFNLGRP_CONNTRACK_EXP_DESTROY
        NFNLGRP_NFTABLES
        NFNLGRP_ACCT_QUOTA
        NFNLGRP_MAX

    # General form of address family dependent message.
    struct Nfgenmsg "nfgenmsg":
        __u8	nfgen_family	# AF_xxx
        __u8	version		# nfnetlink version
        __be16	res_id		# resource id

    enum: NFNETLINK_V0

    # netfilter netlink message types are split in two pieces:
    # 8 bit subsystem, 8bit operation.

    #define NFNL_SUBSYS_ID(x)	((x & 0xff00) >> 8)
    inline int NFNL_SUBSYS_ID(int x)

    #define NFNL_MSG_TYPE(x)	(x & 0x00ff)
    inline int NFNL_MSG_TYPE(int x)

    # No enum here, otherwise __stringify() trick of MODULE_ALIAS_NFNL_SUBSYS()
    # won't work anymore
    enum: NFNL_SUBSYS_NONE
    enum: NFNL_SUBSYS_CTNETLINK
    enum: NFNL_SUBSYS_CTNETLINK_EXP
    enum: NFNL_SUBSYS_QUEUE
    enum: NFNL_SUBSYS_ULOG
    enum: NFNL_SUBSYS_OSF
    enum: NFNL_SUBSYS_IPSET
    enum: NFNL_SUBSYS_ACCT
    enum: NFNL_SUBSYS_CTNETLINK_TIMEOUT
    enum: NFNL_SUBSYS_CTHELPER
    enum: NFNL_SUBSYS_NFTABLES
    enum: NFNL_SUBSYS_NFT_COMPAT
    enum: NFNL_SUBSYS_COUNT

    # Reserved control nfnetlink messages
    enum: NFNL_MSG_BATCH_BEGIN
    enum: NFNL_MSG_BATCH_END

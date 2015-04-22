cdef extern from "linux/netfilter/nfnetlink_conntrack.h" nogil:
    enum CtnlMsgTypes "cntl_msg_types":
        IPCTNL_MSG_CT_NEW
        IPCTNL_MSG_CT_GET
        IPCTNL_MSG_CT_DELETE
        IPCTNL_MSG_CT_GET_CTRZERO
        IPCTNL_MSG_CT_GET_STATS_CPU
        IPCTNL_MSG_CT_GET_STATS
        IPCTNL_MSG_CT_GET_DYING
        IPCTNL_MSG_CT_GET_UNCONFIRMED
        IPCTNL_MSG_MAX

    enum CtnlExpMsgTypes "ctnl_exp_msg_types":
        IPCTNL_MSG_EXP_NEW
        IPCTNL_MSG_EXP_GET
        IPCTNL_MSG_EXP_DELETE
        IPCTNL_MSG_EXP_GET_STATS_CPU
        IPCTNL_MSG_EXP_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrType "ctattr_type":
        CTA_UNSPEC
        CTA_TUPLE_ORIG
        CTA_TUPLE_REPLY
        CTA_STATUS
        CTA_PROTOINFO
        CTA_HELP
        CTA_NAT_SRC
        CTA_NAT			# backwards compatibility
        CTA_TIMEOUT
        CTA_MARK
        CTA_COUNTERS_ORIG
        CTA_COUNTERS_REPLY
        CTA_USE
        CTA_ID
        CTA_NAT_DST
        CTA_TUPLE_MASTER
        CTA_SEQ_ADJ_ORIG
        CTA_NAT_SEQ_ADJ_ORIG	# = CTA_SEQ_ADJ_ORIG,
        CTA_SEQ_ADJ_REPLY
        CTA_NAT_SEQ_ADJ_REPLY	# = CTA_SEQ_ADJ_REPLY,
        CTA_SECMARK		# obsolete
        CTA_ZONE
        CTA_SECCTX
        CTA_TIMESTAMP
        CTA_MARK_MASK
        CTA_LABELS
        CTA_LABELS_MASK
        CTA_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrTuole "ctattr_tuple":
        CTA_TUPLE_UNSPEC
        CTA_TUPLE_IP
        CTA_TUPLE_PROTO
        CTA_TUPLE_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrIp "ctattr_ip":
        CTA_IP_UNSPEC
        CTA_IP_V4_SRC
        CTA_IP_V4_DST
        CTA_IP_V6_SRC
        CTA_IP_V6_DST
        CTA_IP_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrL4proto "ctattr_l4proto":
        CTA_PROTO_UNSPEC
        CTA_PROTO_NUM
        CTA_PROTO_SRC_PORT
        CTA_PROTO_DST_PORT
        CTA_PROTO_ICMP_ID
        CTA_PROTO_ICMP_TYPE
        CTA_PROTO_ICMP_CODE
        CTA_PROTO_ICMPV6_ID
        CTA_PROTO_ICMPV6_TYPE
        CTA_PROTO_ICMPV6_CODE
        CTA_PROTO_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrProtoinfo "ctattr_protoinfo":
        CTA_PROTOINFO_UNSPEC
        CTA_PROTOINFO_TCP
        CTA_PROTOINFO_DCCP
        CTA_PROTOINFO_SCTP
        CTA_PROTOINFO_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrProtoinfoTcp "ctattr_protoinfo_tcp":
        CTA_PROTOINFO_TCP_UNSPEC
        CTA_PROTOINFO_TCP_STATE
        CTA_PROTOINFO_TCP_WSCALE_ORIGINAL
        CTA_PROTOINFO_TCP_WSCALE_REPLY
        CTA_PROTOINFO_TCP_FLAGS_ORIGINAL
        CTA_PROTOINFO_TCP_FLAGS_REPLY
        CTA_PROTOINFO_TCP_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrProtoinfoDccp "ctattr_protoinfo_dccp":
        CTA_PROTOINFO_DCCP_UNSPEC
        CTA_PROTOINFO_DCCP_STATE
        CTA_PROTOINFO_DCCP_ROLE
        CTA_PROTOINFO_DCCP_HANDSHAKE_SEQ
        CTA_PROTOINFO_DCCP_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrProtoinfoSctp "ctattr_protoinfo_sctp":
        CTA_PROTOINFO_SCTP_UNSPEC
        CTA_PROTOINFO_SCTP_STATE
        CTA_PROTOINFO_SCTP_VTAG_ORIGINAL
        CTA_PROTOINFO_SCTP_VTAG_REPLY
        CTA_PROTOINFO_SCTP_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrCounters "ctattr_counters":
        CTA_COUNTERS_UNSPEC
        CTA_COUNTERS_PACKETS		# 64bit counters
        CTA_COUNTERS_BYTES		# 64bit counters
        CTA_COUNTERS32_PACKETS		# old 32bit counters, unused
        CTA_COUNTERS32_BYTES		# old 32bit counters, unused
        CTA_COUNTERS_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrTstamp "ctattr_tstamp":
        CTA_TIMESTAMP_UNSPEC
        CTA_TIMESTAMP_START
        CTA_TIMESTAMP_STOP
        CTA_TIMESTAMP_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrNat "ctattr_nat":
        CTA_NAT_UNSPEC
        CTA_NAT_V4_MINIP
        CTA_NAT_MINIP
        CTA_NAT_V4_MAXIP
        CTA_NAT_MAXIP
        CTA_NAT_PROTO
        CTA_NAT_V6_MINIP
        CTA_NAT_V6_MAXIP
        CTA_NAT_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrProtonat "ctattr_protonat":
        CTA_PROTONAT_UNSPEC
        CTA_PROTONAT_PORT_MIN
        CTA_PROTONAT_PORT_MAX
        CTA_PROTONAT_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrSeqadj "ctattr_seqadj":
        CTA_SEQADJ_UNSPEC
        CTA_SEQADJ_CORRECTION_POS
        CTA_SEQADJ_OFFSET_BEFORE
        CTA_SEQADJ_OFFSET_AFTER
        CTA_SEQADJ_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrNatseq "ctattr_natseq":
        CTA_NAT_SEQ_UNSPEC
        CTA_NAT_SEQ_CORRECTION_POS
        CTA_NAT_SEQ_OFFSET_BEFORE
        CTA_NAT_SEQ_OFFSET_AFTER
        CTA_NAT_SEQ_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrExpect "ctattr_expect":
        CTA_EXPECT_UNSPEC
        CTA_EXPECT_MASTER
        CTA_EXPECT_TUPLE
        CTA_EXPECT_MASK
        CTA_EXPECT_TIMEOUT
        CTA_EXPECT_ID
        CTA_EXPECT_HELP_NAME
        CTA_EXPECT_ZONE
        CTA_EXPECT_FLAGS
        CTA_EXPECT_CLASS
        CTA_EXPECT_NAT
        CTA_EXPECT_FN
        CTA_EXPECT_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrExpectNat "ctattr_expect_nat":
        CTA_EXPECT_NAT_UNSPEC
        CTA_EXPECT_NAT_DIR
        CTA_EXPECT_NAT_TUPLE
        CTA_EXPECT_NAT_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrHelp "ctattr_help":
        CTA_HELP_UNSPEC
        CTA_HELP_NAME
        CTA_HELP_INFO
        CTA_HELP_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrSecctx "ctattr_secctx":
        CTA_SECCTX_UNSPEC
        CTA_SECCTX_NAME
        CTA_SECCTX_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrStatsCpu "ctattr_stats_cpu":
        CTA_STATS_UNSPEC
        CTA_STATS_SEARCHED
        CTA_STATS_FOUND
        CTA_STATS_NEW
        CTA_STATS_INVALID
        CTA_STATS_IGNORE
        CTA_STATS_DELETE
        CTA_STATS_DELETE_LIST
        CTA_STATS_INSERT
        CTA_STATS_INSERT_FAILED
        CTA_STATS_DROP
        CTA_STATS_EARLY_DROP
        CTA_STATS_ERROR
        CTA_STATS_SEARCH_RESTART
        CTA_STATS_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrStatsGlobal "ctattr_stats_global":
        CTA_STATS_GLOBAL_UNSPEC
        CTA_STATS_GLOBAL_ENTRIES
        CTA_STATS_GLOBAL_MAX

    # XXX: avoid - Invalid index type error
    enum: # CtattrExpectStats "ctattr_expect_stats":
        CTA_STATS_EXP_UNSPEC
        CTA_STATS_EXP_NEW
        CTA_STATS_EXP_CREATE
        CTA_STATS_EXP_DELETE
        CTA_STATS_EXP_MAX

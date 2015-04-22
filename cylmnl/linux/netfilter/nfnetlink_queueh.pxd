from libc.stdint cimport uint8_t, uint16_t, uint32_t, uint64_t

cdef extern from "linux/types.h" nogil:
    # http://docs.cython.org/src/userguide/external_C_code.html:
    # you don’t need to match the type exactly, 
    # just use something of the right general kind (int, float, etc). For example,
    ctypedef uint8_t  __u8
    ctypedef uint16_t __u16
    ctypedef uint16_t __be16
    ctypedef uint32_t __u32
    ctypedef uint32_t __be32
    ctypedef uint64_t __aligned_be64

cdef extern from "linux/netfilter/nfnetlink_queue.h" nogil:
    enum NfqlMsgTypes "nfqnl_msg_types":
        NFQNL_MSG_PACKET		# packet from kernel to userspace
        NFQNL_MSG_VERDICT		# verdict from userspace to kernel
        NFQNL_MSG_CONFIG		# connect to a particular queue
        NFQNL_MSG_VERDICT_BATCH		# batchv from userspace to kernel
        NFQNL_MSG_MAX

    struct NfqnlMsgPacketHdr "nfqnl_msg_packet_hdr":
        __be32		packet_id;	# unique ID of packet in queue
        __be16		hw_protocol	# hw protocol (network order)
        __u8		hook		# netfilter hook
    # __attribute__ ((packed))

    struct NfqnlMsgPacketHw "nfqnl_msg_packet_hw":
        __be16		hw_addrlen
        __u16		_pad
        __u8		hw_addr[8]

    struct NfqnlMsgPacketTimestamp "nfqnl_msg_packet_timestamp":
        __aligned_be64	sec
        __aligned_be64	usec

    # XXX: Invalid index type 'NfqnlAttrType'
    enum: # NfqnlAttrType "nfqnl_attr_type":
        NFQA_UNSPEC
        NFQA_PACKET_HDR
        NFQA_VERDICT_HDR		# nfqnl_msg_verdict_hrd
        NFQA_MARK			# __u32 nfmark
        NFQA_TIMESTAMP			# nfqnl_msg_packet_timestamp
        NFQA_IFINDEX_INDEV		# __u32 ifindex
        NFQA_IFINDEX_OUTDEV		# __u32 ifindex
        NFQA_IFINDEX_PHYSINDEV		# __u32 ifindex
        NFQA_IFINDEX_PHYSOUTDEV		# __u32 ifindex
        NFQA_HWADDR			# nfqnl_msg_packet_hw
        NFQA_PAYLOAD			# opaque data payload
        NFQA_CT				# nf_conntrack_netlink.h
        NFQA_CT_INFO			# enum ip_conntrack_info
        NFQA_CAP_LEN			# __u32 length of captured packet
        NFQA_SKB_INFO			# __u32 skb meta information
        NFQA_EXP			# nf_conntrack_netlink.h
        NFQA_UID			# __u32 sk uid
        NFQA_GID			# __u32 sk gid
        NFQA_MAX

    struct NfqnlMsgVerdictHdr "nfqnl_msg_verdict_hdr":
        __be32 verdict;
        __be32 id;

    enum NfqnlMsgConfigCmds "nfqnl_msg_config_cmds":
        NFQNL_CFG_CMD_NONE
        NFQNL_CFG_CMD_BIND
        NFQNL_CFG_CMD_UNBIND
        NFQNL_CFG_CMD_PF_BIND
        NFQNL_CFG_CMD_PF_UNBIND

    struct NfqnlMsgConfigCmd "nfqnl_msg_config_cmd":
        __u8	command	# nfqnl_msg_config_cmds
        __u8	_pad;
        __be16	pf	# AF_xxx for PF_[UN]BIND

    enum NfqnlConfigMode "nfqnl_config_mode":
        NFQNL_COPY_NONE
        NFQNL_COPY_META
        NFQNL_COPY_PACKET

    struct NfqnlMsgConfigParams "nfqnl_msg_config_params":
        __be32	copy_range
        __u8	copy_mode	# enum nfqnl_config_mode
    # __attribute__ ((packed));

    enum NfqnlAttrConfig "nfqnl_attr_config":
        NFQA_CFG_UNSPEC
        NFQA_CFG_CMD			# nfqnl_msg_config_cmd
        NFQA_CFG_PARAMS			# nfqnl_msg_config_params
        NFQA_CFG_QUEUE_MAXLEN		# __u32
        NFQA_CFG_MASK			# identify which flags to change
        NFQA_CFG_FLAGS			# value of these flags (__u32)
        NFQA_CFG_MAX

    # Flags for NFQA_CFG_FLAGS
    enum: NFQA_CFG_F_FAIL_OPEN
    enum: NFQA_CFG_F_CONNTRACK
    enum: NFQA_CFG_F_GSO
    enum: NFQA_CFG_F_UID_GID
    enum: NFQA_CFG_F_MAX

    # flags for NFQA_SKB_INFO
    # packet appears to have wrong checksums, but they are ok
    enum: NFQA_SKB_CSUMNOTREADY
    # packet is GSO (i.e., exceeds device mtu)
    enum: NFQA_SKB_GSO
    # csum not validated (incoming device doesn't support hw checksum, etc.)
    enum: NFQA_SKB_CSUM_NOTVERIFIED

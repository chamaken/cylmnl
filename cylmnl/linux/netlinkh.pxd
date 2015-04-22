from libc.stdint cimport uint16_t, uint32_t

cdef extern from "linux/types.h":
    # http://docs.cython.org/src/userguide/external_C_code.html:
    # you don’t need to match the type exactly, 
    # just use something of the right general kind (int, float, etc). For example,
    ctypedef uint16_t __u16
    ctypedef uint32_t __u32

cdef extern from "linux/netlink.h" nogil:
    enum: NETLINK_ROUTE                 # Routing/device hook
    enum: NETLINK_UNUSED                # Unused number
    enum: NETLINK_USERSOCK              # Reserved for user mode socket protocols
    enum: NETLINK_FIREWALL              # Unused number, formerly ip_queue
    enum: NETLINK_SOCK_DIAG             # socket monitoring
    enum: NETLINK_NFLOG                 # netfilter/iptables ULOG
    enum: NETLINK_XFRM                  # ipsec
    enum: NETLINK_SELINUX               # SELinux event notifications
    enum: NETLINK_ISCSI                 # Open-iSCSI
    enum: NETLINK_AUDIT                 # auditing
    enum: NETLINK_FIB_LOOKUP
    enum: NETLINK_CONNECTOR
    enum: NETLINK_NETFILTER             # netfilter subsystem
    enum: NETLINK_IP6_FW
    enum: NETLINK_DNRTMSG               # DECnet routing messages
    enum: NETLINK_KOBJECT_UEVENT        # Kernel messages to userspace
    enum: NETLINK_GENERIC
    # leave room for NETLINK_DM (DM Events)
    enum: NETLINK_SCSITRANSPORT         # SCSI Transports
    enum: NETLINK_ECRYPTFS
    enum: NETLINK_RDMA
    enum: NETLINK_CRYPTO                # Crypto layer

    enum: NETLINK_INET_DIAG

    enum: MAX_LINKS

    struct Nlmsghdr "nlmsghdr":
        __u32 nlmsg_len      # Length of message including header
        __u16 nlmsg_type     # Message content
        __u16 nlmsg_flags    # Additional flags
        __u32 nlmsg_seq      # Sequence number
        __u32 nlmsg_pid      # Sending process port ID

    # struct Nlmsghdr "nlmsghdr":
    #     __u32 len "nlmsg_len"  # Length of message including header
    #     __u16 type "nlmsg_type"     # Message content
    #     __u16 flags "nlmsg_flags"    # Additional flags
    #     __u32 seq "nlmsg_seq"      # Sequence number
    #     __u32 pid "nlmsg_pid"      # Sending process port ID


    # Flags values
    enum: NLM_F_REQUEST         # It is request message.
    enum: NLM_F_MULTI           # Multipart message, terminated by NLMSG_DONE
    enum: NLM_F_ACK             # Reply with ack, with zero or error code
    enum: NLM_F_ECHO            # Echo this request
    enum: NLM_F_DUMP_INTR       # Dump was inconsistent due to sequence change

    # Modifiers to GET request
    enum: NLM_F_ROOT
    enum: NLM_F_MATCH
    enum: NLM_F_ATOMIC
    enum: NLM_F_DUMP

    # Modifiers to NEW request
    enum:NLM_F_REPLACE  # Override existing
    enum:NLM_F_EXCL     # Do not touch, if it exists
    enum:NLM_F_CREATE   # Create, if it does not exist
    enum:NLM_F_APPEND   # Add to end of list

    # 4.4BSD ADD        NLM_F_CREATE|NLM_F_EXCL
    # 4.4BSD CHANGE     NLM_F_REPLACE
    # True CHANGE       NLM_F_CREATE|NLM_F_REPLACE
    # Append            NLM_F_CREATE
    # Check             NLM_F_EXCL

    enum: NLMSG_ALIGNTO

    #define NLMSG_ALIGN(len) ( ((len)+NLMSG_ALIGNTO-1) & ~(NLMSG_ALIGNTO-1) )
    inline int NLMSG_ALIGN(int len)

    enum: NLMSG_HDRLEN

    #define NLMSG_LENGTH(len) ((len) + NLMSG_HDRLEN)
    inline int NLMSG_LENGTH(int len)

    #define NLMSG_SPACE(len) NLMSG_ALIGN(NLMSG_LENGTH(len))
    inline int NLMSG_SPACE(int len)

    #define NLMSG_DATA(nlh)  ((void*)(((char*)nlh) + NLMSG_LENGTH(0)))
    inline void *NLMSG_DATA(Nlmsghdr *nlh)

    # define NLMSG_NEXT(nlh,len) below as inline cdef

    #define NLMSG_OK(nlh,len) ((len) >= (int)sizeof(struct nlmsghdr) && \
    #			   (nlh)->nlmsg_len >= sizeof(struct nlmsghdr) && \
    #			   (nlh)->nlmsg_len <= (len))
    inline bint NLMSG_OK(Nlmsghdr *nlh, len)

    #define NLMSG_PAYLOAD(nlh,len) ((nlh)->nlmsg_len - NLMSG_SPACE((len)))
    inline int NLMSG_PAYLOAD(Nlmsghdr *nlh, len)

    enum: NLMSG_NOOP    # Nothing.
    enum: NLMSG_ERROR   # Error
    enum: NLMSG_DONE    # End of a dump
    enum: NLMSG_OVERRUN # Data lost

    struct Nlmsgerr "nlmsgerr":
        int             error
        Nlmsghdr        msg

    enum: NLMSG_MIN_TYPE        # reserved control messages

    enum: NETLINK_ADD_MEMBERSHIP
    enum: NETLINK_DROP_MEMBERSHIP
    enum: NETLINK_PKTINFO
    enum: NETLINK_BROADCAST_ERROR
    enum: NETLINK_NO_ENOBUFS
    enum: NETLINK_RX_RING
    enum: NETLINK_TX_RING

    struct NlPktinfo "nl_pktinfo":
        __u32 group

    struct NlMmapReq "nl_mmap_req":
        unsigned int nm_block_size # "nm_block_size"
        unsigned int nm_block_nr   # "nm_block_nr"
        unsigned int nm_frame_size # "nm_frame_size"
        unsigned int nm_frame_nr   # "nm_frame_nr"

    struct NlMmapHdr "nl_mmap_hdr":
        unsigned int  nm_status # "nm_status"
        unsigned int  nm_len    # "nm_len"
        __u32         nm_group  # "nm_group"
        # credentials
        __u32         nm_pid    # "nm_pid"
        __u32         nm_uid    # "nm_uid"
        __u32         nm_gid    # "nm_gid"

    enum nl_mmap_status:
        NL_MMAP_STATUS_UNUSED
        NL_MMAP_STATUS_RESERVED
        NL_MMAP_STATUS_VALID
        NL_MMAP_STATUS_COPY
        NL_MMAP_STATUS_SKIP

    enum: NL_MMAP_MSG_ALIGNMENT

    #define NL_MMAP_MSG_ALIGN(sz)		__ALIGN_KERNEL(sz, NL_MMAP_MSG_ALIGNMENT)
    inline int NL_MMAP_MSG_ALIGN(int sz)

    enum: NL_MMAP_HDRLEN

    enum: NET_MAJOR # Major 36 is reserved for networking

    enum:
        NETLINK_UNCONNECTED
        NETLINK_CONNECTED


    #  <------- NLA_HDRLEN ------> <-- NLA_ALIGN(payload)-->
    # +---------------------+- - -+- - - - - - - - - -+- - -+
    # |        Header       | Pad |     Payload       | Pad |
    # |   (struct nlattr)   | ing |                   | ing |
    # +---------------------+- - -+- - - - - - - - - -+- - -+
    #  <-------------- nlattr->nla_len -------------->
    struct Nlattr "nlattr":
        __u16 nla_len # "nla_len"
        __u16 nlatype # "nla_type"

    # nla_type (16 bits)
    # +---+---+-------------------------------+
    # | N | O | Attribute Type                |
    # +---+---+-------------------------------+
    # N := Carries nested attributes
    # O := Payload stored in network byte order
    #
    # Note: The N and O flag are mutually exclusive.
    enum: NLA_F_NESTED
    enum: NLA_F_NET_BYTEORDER
    enum: NLA_TYPE_MASK
    enum: NLA_ALIGNTO

    #define NLA_ALIGN(len)		(((len) + NLA_ALIGNTO - 1) & ~(NLA_ALIGNTO - 1))
    inline int NLA_ALIGN(int len)

    enum: NLA_HDRLEN


#define NLMSG_NEXT(nlh,len)      ((len) -= NLMSG_ALIGN((nlh)->nlmsg_len), \
#                                 (struct nlmsghdr*)(((char*)(nlh)) + NLMSG_ALIGN((nlh)->nlmsg_len)))
cdef inline Nlmsghdr *NLMSG_NEXT(Nlmsghdr *nlh, int *len) nogil:
    len[0] -= NLMSG_ALIGN(nlh.nlmsg_len)
    return <Nlmsghdr *>(<char *>nlh + NLMSG_ALIGN(nlh.nlmsg_len))

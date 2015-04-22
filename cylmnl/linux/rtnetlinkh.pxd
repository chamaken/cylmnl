from libc.stdint cimport int32_t, uint8_t, uint16_t, uint32_t, uint64_t

cdef extern from "linux/types.h":
    ctypedef int32_t  __s32
    ctypedef uint8_t  __u8
    ctypedef uint16_t __u16
    ctypedef uint32_t __u32
    ctypedef uint64_t __u64

cdef extern from "linux/socket.h":
    struct __kernel_sa_family_t:
        pass

from cylmnl.linux.netlinkh cimport Nlmsghdr, NLMSG_ALIGN, NLMSG_PAYLOAD

cdef extern from "linux/rtnetlink.h":
    # rtnetlink families. Values up to 127 are reserved for real address
    # families, values above 128 may be used arbitrarily.
    enum: RTNL_FAMILY_IPMR
    enum: RTNL_FAMILY_IP6MR
    enum: RTNL_FAMILY_MAX

    #
    # Routing/neighbour discovery messages.
    #
    # Types of messages
    enum: RTM_BASE
    enum: RTM_NEWLINK
    enum: RTM_DELLINK
    enum: RTM_GETLINK
    enum: RTM_SETLINK
    enum: RTM_NEWADDR
    enum: RTM_DELADDR
    enum: RTM_GETADDR
    enum: RTM_NEWROUTE
    enum: RTM_DELROUTE
    enum: RTM_GETROUTE
    enum: RTM_NEWNEIGH
    enum: RTM_DELNEIGH
    enum: RTM_GETNEIGH
    enum: RTM_NEWRULE
    enum: RTM_DELRULE
    enum: RTM_GETRULE
    enum: RTM_NEWQDISC
    enum: RTM_DELQDISC
    enum: RTM_GETQDISC
    enum: RTM_NEWTCLASS
    enum: RTM_DELTCLASS
    enum: RTM_GETTCLASS
    enum: RTM_NEWTFILTER
    enum: RTM_DELTFILTER
    enum: RTM_GETTFILTER
    enum: RTM_NEWACTION
    enum: RTM_DELACTION
    enum: RTM_GETACTION
    enum: RTM_NEWPREFIX
    enum: RTM_GETMULTICAST
    enum: RTM_GETANYCAST
    enum: RTM_NEWNEIGHTBL
    enum: RTM_GETNEIGHTBL
    enum: RTM_SETNEIGHTBL
    enum: RTM_NEWNDUSEROPT
    enum: RTM_NEWADDRLABEL
    enum: RTM_DELADDRLABEL
    enum: RTM_GETADDRLABEL
    enum: RTM_GETDCB
    enum: RTM_SETDCB
    enum: RTM_NEWNETCONF
    enum: RTM_GETNETCONF
    enum: RTM_NEWMDB
    enum: RTM_DELMDB
    enum: RTM_GETMDB
    enum: RTM_NEWNSID
    enum: RTM_DELNSID
    enum: RTM_GETNSID
    enum: RTM_MAX

    enum: RTM_NR_MSGTYPES
    enum: RTM_NR_FAMILIES

    #define RTM_FAM(cmd)	(((cmd) - RTM_BASE) >> 2)
    int RTM_FAM(int cmd)

    # Generic structure for encapsulation of optional route information.
    # It is reminiscent of sockaddr, but with sa_family replaced
    # with attribute type.
    struct Rtattr "rtattr":
        unsigned short	rta_len
        unsigned short	rta_type

    # Macros to handle rtattributes
    enum: RTA_ALIGNTO

    #define RTA_ALIGN(len) ( ((len)+RTA_ALIGNTO-1) & ~(RTA_ALIGNTO-1) )
    inline int RTA_ALIGN(int len)

    #define RTA_OK(rta,len) ((len) >= (int)sizeof(struct rtattr) && \
    #			 (rta)->rta_len >= sizeof(struct rtattr) && \
    #			 (rta)->rta_len <= (len))
    inline bint RTA_OK(Rtattr *rta, int len)

    #define RTA_NEXT(rta,attrlen): below as inline cdef

    #define RTA_LENGTH(len)	(RTA_ALIGN(sizeof(struct rtattr)) + (len))
    inline int RTA_LENGTH(int len)

    #define RTA_SPACE(len)	RTA_ALIGN(RTA_LENGTH(len))
    inline int RTA_SPACE(int len)

    #define RTA_DATA(rta)   ((void*)(((char*)(rta)) + RTA_LENGTH(0)))
    inline void *RTA_DATA(Rtattr *rta)

    #define RTA_PAYLOAD(rta) ((int)((rta)->rta_len) - RTA_LENGTH(0))
    inline int RTA_PAYLOAD(Rtattr *rta)


    # Definitions used in routing table administration.
    struct Rtmsg "rtmsg":
        unsigned char		rtm_family
        unsigned char		rtm_dst_len
        unsigned char		rtm_src_len
        unsigned char		rtm_tos
        unsigned char		rtm_table	# Routing table id
        unsigned char		rtm_protocol	# Routing protocol; see below
        unsigned char		rtm_scope	# See below
        unsigned char		rtm_type	# See below
        unsigned		rtm_flags

    enum:
        RTN_UNSPEC
        RTN_UNICAST		# Gateway or direct route
        RTN_LOCAL		# Accept locally
        RTN_BROADCAST		# Accept locally as broadcast,
        			#  send as broadcast
        RTN_ANYCAST		# Accept locally as broadcast,
        			#  but send as unicast
        RTN_MULTICAST		# Multicast route
        RTN_BLACKHOLE		# Drop
        RTN_UNREACHABLE		# Destination is unreachable
        RTN_PROHIBIT		# Administratively prohibited
        RTN_THROW		# Not in this table
        RTN_NAT			# Translate this address
        RTN_XRESOLVE		# Use external resolver
        RTN_MAX

    # rtm_protocol
    enum:
        RTPROT_UNSPEC
        RTPROT_REDIRECT	# Route installed by ICMP redirects;
        		# not used by current IPv4
        RTPROT_KERNEL	# Route installed by kernel
        RTPROT_BOOT	# Route installed during boot
        RTPROT_STATIC	# Route installed by administrator

    # Values of protocol >= RTPROT_STATIC are not interpreted by kernel;
    # they are just passed from user and back as is.
    # It will be used by hypothetical multiple routing daemons.
    # Note that protocol values should be standardized in order to
    # avoid conflicts.
    enum:
        RTPROT_GATED	# Apparently, GateD
        RTPROT_RA	# RDISC/ND router advertisements
        RTPROT_MRT	# Merit MRT
        RTPROT_ZEBRA	# Zebra
        RTPROT_BIRD	# BIRD
        RTPROT_DNROUTED	# DECnet routing daemon
        RTPROT_XORP	# XORP
        RTPROT_NTK	# Netsukuku
        RTPROT_DHCP	# DHCP client
        RTPROT_MROUTED	# Multicast daemon
        RTPROT_BABEL	# Babel daemon

    # rtm_scope
    #
    # Really it is not scope, but sort of distance to the destination.
    # NOWHERE are reserved for not existing destinations, HOST is our
    # local addresses, LINK are destinations, located on directly attached
    # link and UNIVERSE is everywhere in the Universe.
    #
    # Intermediate values are also possible f.e. interior routes
    # could be assigned a value between UNIVERSE and LINK.
    enum RtScopeT:
        RT_SCOPE_UNIVERSE
        # User defined values
        RT_SCOPE_SITE
        RT_SCOPE_LINK
        RT_SCOPE_HOST
        RT_SCOPE_NOWHERE

    # rtm_flags
    enum:
        RTM_F_NOTIFY		# Notify user of route change
        RTM_F_CLONED		# This route is cloned
        RTM_F_EQUALIZE		# Multipath equalizer: NI
        RTM_F_PREFIX		# Prefix addresses

    # Reserved table identifiers
    enum RtClassT:
        RT_TABLE_UNSPEC
        # User defined values
        RT_TABLE_COMPAT
        RT_TABLE_DEFAULT
        RT_TABLE_MAIN
        RT_TABLE_LOCAL
        RT_TABLE_MAX

    # Routing message attributes
    enum RtattrTypeT:
        RTA_UNSPEC
        RTA_DST
        RTA_SRC
        RTA_IIF
        RTA_OIF
        RTA_GATEWAY
        RTA_PRIORITY
        RTA_PREFSRC
        RTA_METRICS
        RTA_MULTIPATH
        RTA_PROTOINFO	# no longer used
        RTA_FLOW
        RTA_CACHEINFO
        RTA_SESSION	# no longer used
        RTA_MP_ALGO	# no longer used
        RTA_TABLE
        RTA_MARK
        RTA_MFC_STATS
        RTA_VIA
        RTA_NEWDST
        RTA_PREF
        RTA_MAX

    #define RTM_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct rtmsg))))
    inline Rtattr *RTM_RTA(void *r)

    #define RTM_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct rtmsg))
    inline int RTM_PAYLOAD(Nlmsghdr *n)


    # RTM_MULTIPATH --- array of struct rtnexthop.
    #
    # "struct rtnexthop" describes all necessary nexthop information,
    # i.e. parameters of path to a destination via this nexthop.
    #
    # At the moment it is impossible to set different prefsrc, mtu, window
    # and rtt for different paths from multipath.
    struct Rtnexthop "rtnexthop":
        unsigned short		rtnh_len
        unsigned char		rtnh_flags
        unsigned char		rtnh_hops
        int			rtnh_ifindex

    # rtnh_flags
    enum:
        RTNH_F_DEAD		# Nexthop is dead (used by multipath)
        RTNH_F_PERVASIVE	# Do recursive gateway lookup
        RTNH_F_ONLINK		# Gateway is forced on link
        RTNH_F_EXTERNAL		# Route installed externally

    # Macros to handle hexthops
    enum: RTNH_ALIGNTO

    #define RTNH_ALIGN(len) ( ((len)+RTNH_ALIGNTO-1) & ~(RTNH_ALIGNTO-1) )
    inline int RTNH_ALIGN(int len)

    #define RTNH_OK(rtnh,len) ((rtnh)->rtnh_len >= sizeof(struct rtnexthop) && \
    #			   ((int)(rtnh)->rtnh_len) <= (len))
    inline bint RTNH_OK(Rtnexthop *rtnh, int len)

    #define RTNH_NEXT(rtnh)	((struct rtnexthop*)(((char*)(rtnh)) + RTNH_ALIGN((rtnh)->rtnh_len)))
    inline Rtnexthop *RTNH_NEXT(Rtnexthop *rtnh)

    #define RTNH_LENGTH(len) (RTNH_ALIGN(sizeof(struct rtnexthop)) + (len))
    inline int RTNH_LENGTH(int len)

    #define RTNH_SPACE(len)	RTNH_ALIGN(RTNH_LENGTH(len))
    inline int RTNH_SPACE(int len)

    #define RTNH_DATA(rtnh)	  ((struct rtattr*)(((char*)(rtnh)) + RTNH_LENGTH(0)))
    inline Rtattr *RTNH_DATA(Rtnexthop *rtnh)


    # RTA_VIA
    struct Rtvia "rtvia":
        __kernel_sa_family_t	rtvia_family
        __u8			rtvia_addr[0]

    # RTM_CACHEINFO
    enum: RTNETLINK_HAVE_PEERINFO
    struct RtaCacheinfo "rta_cacheinfo":
        __u32	rta_clntref
        __u32	rta_lastuse
        __s32	rta_expires
        __u32	rta_error
        __u32	rta_used
        __u32	rta_id
        __u32	rta_ts
        __u32	rta_tsage

    # RTM_METRICS --- array of struct rtattr with types of RTAX_*
    enum:
        RTAX_UNSPEC
        RTAX_LOCK
        RTAX_MTU
        RTAX_WINDOW
        RTAX_RTT
        RTAX_RTTVAR
        RTAX_SSTHRESH
        RTAX_CWND
        RTAX_ADVMSS
        RTAX_REORDERING
        RTAX_HOPLIMIT
        RTAX_INITCWND
        RTAX_FEATURES
        RTAX_RTO_MIN
        RTAX_INITRWND
        RTAX_QUICKACK
        RTAX_CC_ALGO
        RTAX_MAX

    enum:
        RTAX_FEATURE_ECN
        RTAX_FEATURE_SACK
        RTAX_FEATURE_TIMESTAMP
        RTAX_FEATURE_ALLFRAG

    struct RtaSessionPorts:
        __u16	sport
        __u16	dport
    struct RtaSessionIcmpt:    
        __u8	type
        __u8	code
        __u16	ident
    union _U_RtaSession:
        RtaSessionPorts port
        RtaSessionIcmpt icmpt
        __u32 spi

    struct RtaSession "rta_session":
        __u8	proto
        __u8	pad1
        __u16	pad2
        _U_RtaSession u

    struct RtaMfcStats "rta_mfc_stats":
        __u64	mfcs_packets
        __u64	mfcs_bytes
        __u64	mfcs_wrong_if

    #
    # General form of address family dependent message.
    #
    struct Rtgenmsg "rtgenmsg":
        unsigned char		rtgen_family;

    # Link layer specific messages.

    # struct ifinfomsg
    # passes link level specific information, not dependent
    # on network protocol.
    struct Ifinfomsg "ifinfomsg":
        unsigned char	ifi_family
        unsigned char	__ifi_pad
        unsigned short	ifi_type		# ARPHRD_*
        int		ifi_index		# Link index
        unsigned	ifi_flags		# IFF_* flags
        unsigned	ifi_change		# IFF_* change mask

    # prefix information
    struct Prefixmsg "prefixmsg":
        unsigned char	prefix_family
        unsigned char	prefix_pad1
        unsigned short	prefix_pad2
        int		prefix_ifindex
        unsigned char	prefix_type
        unsigned char	prefix_len
        unsigned char	prefix_flags
        unsigned char	prefix_pad3

    enum:
        PREFIX_UNSPEC,
        PREFIX_ADDRESS,
        PREFIX_CACHEINFO,
        PREFIX_MAX

    struct PrefixCacheinfo "prefix_cacheinfo":
        __u32	preferred_time
        __u32	valid_time

    # Traffic control messages.
    struct Tcmsg "tcmsg":
        unsigned char	tcm_family
        unsigned char	tcm__pad1
        unsigned short	tcm__pad2
        int		tcm_ifindex
        __u32		tcm_handle
        __u32		tcm_parent
        __u32		tcm_info

    enum:
        TCA_UNSPEC
        TCA_KIND
        TCA_OPTIONS
        TCA_STATS
        TCA_XSTATS
        TCA_RATE
        TCA_FCNT
        TCA_STATS2
        TCA_STAB
        TCA_MAX

    #define TCA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcmsg))))
    inline Rtattr *TCA_RTA(void *r) # XXX: not void *, but Rtattr * ?

    #define TCA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcmsg))
    inline int TCA_PAYLOAD(Nlmsghdr *n)

    # Neighbor Discovery userland options
    struct Nduseroptmsg "nduseroptmsg":
        unsigned char	nduseropt_family
        unsigned char	nduseropt_pad1
        unsigned short	nduseropt_opts_len	# Total length of options
        int		nduseropt_ifindex
        __u8		nduseropt_icmp_type
        __u8		nduseropt_icmp_code
        unsigned short	nduseropt_pad2
        unsigned int	nduseropt_pad3
        # Followed by one or more ND options

    enum:
        NDUSEROPT_UNSPEC,
        NDUSEROPT_SRCADDR,
        NDUSEROPT_MAX

    # RTnetlink multicast groups - backwards compatibility for userspace
    enum:
        RTMGRP_LINK
        RTMGRP_NOTIFY
        RTMGRP_NEIGH
        RTMGRP_TC

        RTMGRP_IPV4_IFADDR
        RTMGRP_IPV4_MROUTE
        RTMGRP_IPV4_ROUTE
        RTMGRP_IPV4_RULE

        RTMGRP_IPV6_IFADDR
        RTMGRP_IPV6_MROUTE
        RTMGRP_IPV6_ROUTE
        RTMGRP_IPV6_IFINFO

        RTMGRP_DECnet_IFADDR
        RTMGRP_DECnet_ROUTE

        RTMGRP_IPV6_PREFIX


    # RTnetlink multicast groups
    enum RtnetlinkGroups:
        RTNLGRP_NONE
        RTNLGRP_LINK
        RTNLGRP_NOTIFY
        RTNLGRP_NEIGH
        RTNLGRP_TC
        RTNLGRP_IPV4_IFADDR
        RTNLGRP_IPV4_MROUTE
        RTNLGRP_IPV4_ROUTE
        RTNLGRP_IPV4_RULE
        RTNLGRP_IPV6_IFADDR
        RTNLGRP_IPV6_MROUTE
        RTNLGRP_IPV6_ROUTE
        RTNLGRP_IPV6_IFINFO
        RTNLGRP_DECnet_IFADDR
        RTNLGRP_NOP2
        RTNLGRP_DECnet_ROUTE
        RTNLGRP_DECnet_RULE
        RTNLGRP_NOP4
        RTNLGRP_IPV6_PREFIX
        RTNLGRP_IPV6_RULE
        RTNLGRP_ND_USEROPT
        RTNLGRP_PHONET_IFADDR
        RTNLGRP_PHONET_ROUTE
        RTNLGRP_DCB
        RTNLGRP_IPV4_NETCONF
        RTNLGRP_IPV6_NETCONF
        RTNLGRP_MDB
        RTNLGRP_MPLS_ROUTE
        RTNLGRP_NSID
        RTNLGRP_MAX

    # TC action piece
    struct Tcamsg "tcamsg":
        unsigned char	tca_family
        unsigned char	tca__pad1
        unsigned short	tca__pad2

    #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
    inline Rtattr *TA_RTA(void *r) # XXX: not void *, but Rtattr * ?

    #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
    inline int TA_PAYLOAD(Nlmsghdr *n)

    enum: 
        TCA_ACT_TAB	# attr type must be >=1
        TCAA_MAX

    # New extended info filters for IFLA_EXT_MASK
    enum:
        RTEXT_FILTER_VF
        RTEXT_FILTER_BRVLAN
        RTEXT_FILTER_BRVLAN_COMPRESSED


#define RTA_NEXT(rta,attrlen)	((attrlen) -= RTA_ALIGN((rta)->rta_len), \
#				 (struct rtattr*)(((char*)(rta)) + RTA_ALIGN((rta)->rta_len)))
cdef inline Rtattr *RTA_NEXT(Rtattr *rta, int *attrlen):
    attrlen[0] -= RTA_ALIGN(rta.rta_len)
    return <Rtattr *>(<char *>(rta) + RTA_ALIGN(rta.rta_len))

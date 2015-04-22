cdef extern from "linux/netfilter/nf_conntrack_common.h" nogil:
    # Connection state tracking for netfilter.  This is separated from,
    # but required by, the NAT layer; it can also be used by an iptables
    # extension.
    enum IpConntrackInfo "ip_conntrack_info":
	# Part of an established connection (either direction).
	IP_CT_ESTABLISHED

	# Like NEW, but related to an existing connection, or ICMP error
	# (in either direction).
	IP_CT_RELATED

	# Started a new connection to track (only
        # IP_CT_DIR_ORIGINAL); may be a retransmission.
	IP_CT_NEW

	# >= this indicates reply direction
	IP_CT_IS_REPLY

	IP_CT_ESTABLISHED_REPLY
	IP_CT_RELATED_REPLY
	IP_CT_NEW_REPLY
	# Number of distinct IP_CT types (no NEW in reply dirn).
	IP_CT_NUMBER

    enum: NF_CT_STATE_INVALID_BIT

    #define NF_CT_STATE_BIT(ctinfo)			(1 << ((ctinfo) % IP_CT_IS_REPLY + 1))
    inline int NF_CT_STATE_BIT(int ctinfo)

    enum: NF_CT_STATE_UNTRACKED_BIT

    # Bitset representing status of connection.
    enum IpConntrackStatus "ip_conntrack_status":
	# It's an expected connection: bit 0 set.  This bit never changed
	IPS_EXPECTED_BIT
	IPS_EXPECTED

	# We've seen packets both ways: bit 1 set.  Can be set, not unset.
	IPS_SEEN_REPLY_BIT
	IPS_SEEN_REPLY

	# Conntrack should never be early-expired.
	IPS_ASSURED_BIT
	IPS_ASSURED

	# Connection is confirmed: originating packet has left box
	IPS_CONFIRMED_BIT
	IPS_CONFIRMED

	# Connection needs src nat in orig dir.  This bit never changed.
	IPS_SRC_NAT_BIT
	IPS_SRC_NAT

	# Connection needs dst nat in orig dir.  This bit never changed.
	IPS_DST_NAT_BIT
	IPS_DST_NAT

	# Both together.
	IPS_NAT_MASK

	# Connection needs TCP sequence adjusted.
	IPS_SEQ_ADJUST_BIT
	IPS_SEQ_ADJUST

	# NAT initialization bits.
	IPS_SRC_NAT_DONE_BIT
	IPS_SRC_NAT_DONE

	IPS_DST_NAT_DONE_BIT
	IPS_DST_NAT_DONE

	# Both together
	IPS_NAT_DONE_MASK

	# Connection is dying (removed from lists), can not be unset.
	IPS_DYING_BIT
	IPS_DYING

	# Connection has fixed timeout.
	IPS_FIXED_TIMEOUT_BIT
	IPS_FIXED_TIMEOUT

	# Conntrack is a template
	IPS_TEMPLATE_BIT
	IPS_TEMPLATE

	# Conntrack is a fake untracked entry
	IPS_UNTRACKED_BIT
	IPS_UNTRACKED

	# Conntrack got a helper explicitly attached via CT target.
	IPS_HELPER_BIT
	IPS_HELPER

    # Connection tracking event types
    enum IpConntrackEvents "ip_conntrack_events":
	IPCT_NEW		# new conntrack
	IPCT_RELATED		# related conntrack
	IPCT_DESTROY		# destroyed conntrack
	IPCT_REPLY		# connection has seen two-way traffic
	IPCT_ASSURED		# connection status has changed to assured
	IPCT_PROTOINFO		# protocol information has changed
	IPCT_HELPER		# new helper has been set
	IPCT_MARK		# new mark has been set
	IPCT_SEQADJ		# sequence adjustment has changed
	IPCT_NATSEQADJ
	IPCT_SECMARK		# new security mark has been set
	IPCT_LABEL		# new connlabel has been set

    enum IpConntrackExpectEvents "ip_conntrack_expect_events":
	IPEXP_NEW		# new expectation
	IPEXP_DESTROY		# destroyed expectation

    # expectation flags
    enum: NF_CT_EXPECT_PERMANENT
    enum: NF_CT_EXPECT_INACTIVE
    enum: NF_CT_EXPECT_USERSPACE

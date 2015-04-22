from libc.stdint cimport uint16_t, uint32_t

cdef extern from "linux/types.h" nogil:
    # http://docs.cython.org/src/userguide/external_C_code.html:
    # you don’t need to match the type exactly, 
    # just use something of the right general kind (int, float, etc). For example,
    ctypedef uint16_t __u16
    ctypedef uint32_t __u32
    ctypedef uint32_t __be32

cdef extern from "netinet/in.h" nogil:
    struct InAddr:
        pass
    struct In6Addr:
        pass

cdef extern from "linux/netfilter.h" nogil:
    # Responses from hook functions.
    enum: NF_DROP
    enum: NF_ACCEPT
    enum: NF_STOLEN
    enum: NF_QUEUE
    enum: NF_REPEAT
    enum: NF_STOP
    enum: NF_MAX_VERDICT

    # we overload the higher bits for encoding auxiliary data such as the queue
    # number or errno values. Not nice, but better than additional function
    # arguments.
    enum: NF_VERDICT_MASK

    # extra verdict flags have mask 0x0000ff00
    enum: NF_VERDICT_FLAG_QUEUE_BYPASS

    # queue number (NF_QUEUE) or errno (NF_DROP)
    enum: NF_VERDICT_QMASK
    enum: NF_VERDICT_QBITS

    #define NF_QUEUE_NR(x) ((((x) << 16) & NF_VERDICT_QMASK) | NF_QUEUE)
    inline int NF_QUEUE_NR(int x)

    #define NF_DROP_ERR(x) (((-x) << 16) | NF_DROP)
    inline int NF_DROP_ERR(int x)

    # only for userspace compatibility
    # Generic cache responses from hook functions.
    # <= 0x2000 is used for protocol-flags.
    enum: NFC_UNKNOWN
    enum: NFC_ALTERED

    # NF_VERDICT_BITS should be 8 now, but userspace might break if this changes
    enum: NF_VERDICT_BITS

    enum NfInetHooks "nf_inet_hooks":
        NF_INET_PRE_ROUTING
        NF_INET_LOCAL_IN
        NF_INET_FORWARD
        NF_INET_LOCAL_OUT
        NF_INET_POST_ROUTING
        NF_INET_NUMHOOKS

    enum:
        NFPROTO_UNSPEC
        NFPROTO_INET
        NFPROTO_IPV4
        NFPROTO_ARP
        NFPROTO_BRIDGE
        NFPROTO_IPV6
        NFPROTO_DECNET
        NFPROTO_NUMPROTO

    # XXX: InAddr in is not allowed
    union NfInetAddr "nf_inet_addr":
        __u32		all[4]
        __be32		ip
        __be32		ip6[4]
        InAddr		inaddr
        In6Addr		in6addr

from posix.types cimport pid_t
from libcpp cimport bool
from libc.stdint cimport uint8_t, uint16_t, uint32_t, uint64_t
cdef extern from "stdio.h":
    ctypedef struct FILE

cdef extern from "sys/socket.h":
    ctypedef unsigned int socklen_t

cimport cylmnl.linux.netlinkh as netlink

cdef extern from "libmnl/libmnl.h" nogil:
    #
    # Netlink socket API
    #
    enum: MNL_SOCKET_AUTOPID
    enum: MNL_SOCKET_BUFFER_SIZE

    # enum RingType:
    #     MNL_RING_RX
    #     MNL_RING_TX

    struct Socket "mnl_socket":
        pass
    # struct Ring "ring":
    #     pass

    #define MNL_FRAME_PAYLOAD(frame) ((void *)(frame) + NL_MMAP_HDRLEN)
    void *MNL_FRAME_PAYLOAD(netlink.NlMmapHdr *frame)

    Socket * socket_open "mnl_socket_open" (int type)
    Socket * socket_fdopen "mnl_socket_fdopen" (int fd)
    int socket_bind "mnl_socket_bind" (Socket *nl, unsigned int groups, pid_t pid)
    int socket_close "mnl_socket_close" (Socket *nl)
    int socket_get_fd "mnl_socket_get_fd" (const Socket *nl)
    unsigned int socket_get_portid "mnl_socket_get_portid" (const Socket *nl)
    ssize_t socket_sendto "mnl_socket_sendto" (const Socket *nl, const void *req, size_t siz)
    ssize_t socket_recvfrom "mnl_socket_recvfrom"(const Socket *nl, void *buf, size_t siz)
    int socket_setsockopt "mnl_socket_setsockopt" (const Socket *nl, int type, void *buf, socklen_t len)
    int socket_getsockopt" mnl_socket_getsockopt" (const Socket *nl, int type, void *buf, socklen_t *len)
    # int socket_set_ringopt "mnl_socket_set_ringopt" (Socket *nl, enum RingType type,
    #				  unsigned int block_size, unsigned int block_nf,
    #				  unsigned int frame_size, unsigned int frame_nr)
    # int socket_map_ring "mnl_socket_map_ring" (Socket *nl)
    # int socket_unmap_ring "mnl_socket_unmap_ring" (Socket *nl)
    # Ring * socket_get_ring "mnl_socket_get_ring"(const Socket *nl, enum ring_type type)
    # void ring_advance "mnl_ring_advance" (Ring *ring)
    # netlink.NlMmapHdr * ring_get_frame "mnl_ring_get_frame"(const Ring *ring)


    #
    # Netlink message API
    #
    enum: MNL_ALIGNTO

    #define MNL_ALIGN(len)		(((len)+MNL_ALIGNTO-1) & ~(MNL_ALIGNTO-1))
    int MNL_ALIGN(int len)

    enum: MNL_NLMSG_HDRLEN

    size_t nlmsg_size "mnl_nlmsg_size" (size_t len)
    size_t nlmsg_get_payload_len " mnl_nlmsg_get_payload_len" (const netlink.Nlmsghdr *nlh)

    # Netlink message header builder
    netlink.Nlmsghdr * nlmsg_put_header "mnl_nlmsg_put_header" (void *buf)
    void * nlmsg_put_extra_header "mnl_nlmsg_put_extra_header" (netlink.Nlmsghdr *nlh, size_t size)

    # Netlink message iterators
    bool nlmsg_ok "mnl_nlmsg_ok" (const netlink.Nlmsghdr *nlh, int len)
    netlink.Nlmsghdr * nlmsg_next "mnl_nlmsg_next" (const netlink.Nlmsghdr *nlh, int *len)

    # Netlink sequence tracking
    bool nlmsg_seq_ok "mnl_nlmsg_seq_ok" (const netlink.Nlmsghdr *nlh, unsigned int seq)

    # Netlink portID checking
    bool nlmsg_portid_ok "mnl_nlmsg_portid_ok" (const netlink.Nlmsghdr *nlh, unsigned int portid)

    # Netlink message getters
    void * nlmsg_get_payload "mnl_nlmsg_get_payload" (const netlink.Nlmsghdr *nlh)
    void * nlmsg_get_payload_offset "mnl_nlmsg_get_payload_offset" (const netlink.Nlmsghdr *nlh, size_t offset)
    void * nlmsg_get_payload_tail "mnl_nlmsg_get_payload_tail" (const netlink.Nlmsghdr *nlh)

    # Netlink message printer
    void nlmsg_fprintf "mnl_nlmsg_fprintf" (FILE *fd, const void *data, size_t datalen, size_t extra_header_size)

    # Message batch helpers
    struct NlmsgBatch "mnl_nlmsg_batch":
        pass

    NlmsgBatch * nlmsg_batch_start "mnl_nlmsg_batch_start" (void *buf, size_t bufsiz)
    bool nlmsg_batch_next "mnl_nlmsg_batch_next" (NlmsgBatch *b)
    void nlmsg_batch_stop "mnl_nlmsg_batch_stop" (NlmsgBatch *b)
    size_t nlmsg_batch_size "mnl_nlmsg_batch_size" (NlmsgBatch *b)
    void nlmsg_batch_reset "mnl_nlmsg_batch_reset" (NlmsgBatch *b)
    void * nlmsg_batch_head "mnl_nlmsg_batch_head" (NlmsgBatch *b)
    void * nlmsg_batch_current "mnl_nlmsg_batch_current" (NlmsgBatch *b)
    bool nlmsg_batch_is_empty "mnl_nlmsg_batch_is_empty" (NlmsgBatch *b)
    # void nlmsg_batch_reset_buffer "mnl_nlmsg_batch_reset_buffer" (NlmsgBatch *b, void *buf, size_t limit)

    #
    # Netlink attributes API
    #
    enum: MNL_ATTR_HDRLEN

    # TLV attribute getters
    uint16_t attr_get_type "mnl_attr_get_type" (const netlink.Nlattr *attr)
    uint16_t attr_get_len "mnl_attr_get_len" (const netlink.Nlattr *attr)
    uint16_t attr_get_payload_len "mnl_attr_get_payload_len" (const netlink.Nlattr *attr)
    void * attr_get_payload "mnl_attr_get_payload"(const netlink.Nlattr *attr)
    uint8_t attr_get_u8 "mnl_attr_get_u8" (const netlink.Nlattr *attr)
    uint16_t attr_get_u16 "mnl_attr_get_u16" (const netlink.Nlattr *attr)
    uint32_t attr_get_u32 "mnl_attr_get_u32"(const netlink.Nlattr *attr)
    uint64_t attr_get_u64 "mnl_attr_get_u64"(const netlink.Nlattr *attr)
    const char * attr_get_str "mnl_attr_get_str" (const netlink.Nlattr *attr)

    # TLV attribute putters
    void attr_put "mnl_attr_put" (netlink.Nlmsghdr *nlh, uint16_t type, size_t len, const void *data)
    void attr_put_u8 "mnl_attr_put_u8" (netlink.Nlmsghdr *nlh, uint16_t type, uint8_t data)
    void attr_put_u16 "mnl_attr_put_u16" (netlink.Nlmsghdr *nlh, uint16_t type, uint16_t data)
    void attr_put_u32 "mnl_attr_put_u32" (netlink.Nlmsghdr *nlh, uint16_t type, uint32_t data)
    void attr_put_u64 "mnl_attr_put_u64" (netlink.Nlmsghdr *nlh, uint16_t type, uint64_t data)
    void attr_put_str "mnl_attr_put_str" (netlink.Nlmsghdr *nlh, uint16_t type, const char *data)
    void attr_put_strz "mnl_attr_put_strz" (netlink.Nlmsghdr *nlh, uint16_t type, const char *data)

    # TLV attribute putters with buffer boundary checkings
    bool attr_put_check "mnl_attr_put_check" (netlink.Nlmsghdr *nlh, size_t buflen, uint16_t type, size_t len, const void *data)
    bool attr_put_u8_check "mnl_attr_put_u8_check" (netlink.Nlmsghdr *nlh, size_t buflen, uint16_t type, uint8_t data)
    bool attr_put_u16_check "mnl_attr_put_u16_check" (netlink.Nlmsghdr *nlh, size_t buflen, uint16_t type, uint16_t data)
    bool attr_put_u32_check "mnl_attr_put_u32_check" (netlink.Nlmsghdr *nlh, size_t buflen, uint16_t type, uint32_t data)
    bool attr_put_u64_check "mnl_attr_put_u64_check" (netlink.Nlmsghdr *nlh, size_t buflen, uint16_t type, uint64_t data)
    bool attr_put_str_check "mnl_attr_put_str_check" (netlink.Nlmsghdr *nlh, size_t buflen, uint16_t type, const char *data)
    bool attr_put_strz_check "mnl_attr_put_strz_check" (netlink.Nlmsghdr *nlh, size_t buflen, uint16_t type, const char *data)

    # TLV attribute nesting
    netlink.Nlattr * attr_nest_start "mnl_attr_nest_start" (netlink.Nlmsghdr *nlh, uint16_t type)
    netlink.Nlattr * attr_nest_start_check "mnl_attr_nest_start_check" (netlink.Nlmsghdr *nlh, size_t buflen, uint16_t type)
    void attr_nest_end "mnl_attr_nest_end" (netlink.Nlmsghdr *nlh, netlink.Nlattr *start)
    void attr_nest_cancel "mnl_attr_nest_cancel"(netlink.Nlmsghdr *nlh, netlink.Nlattr *start)

    # TLV validation
    int attr_type_valid "mnl_attr_type_valid" (const netlink.Nlattr *attr, uint16_t maxtype)

    enum AttrDataType:
        MNL_TYPE_UNSPEC
        MNL_TYPE_U8
        MNL_TYPE_U16
        MNL_TYPE_U32
        MNL_TYPE_U64
        MNL_TYPE_STRING
        MNL_TYPE_FLAG
        MNL_TYPE_MSECS
        MNL_TYPE_NESTED
        MNL_TYPE_NESTED_COMPAT
        MNL_TYPE_NUL_STRING
        MNL_TYPE_BINARY
        MNL_TYPE_MAX

    int attr_validate "mnl_attr_validate" (const netlink.Nlattr *attr, AttrDataType type)
    int attr_validate2 "mnl_attr_validate2" (const netlink.Nlattr *attr, AttrDataType type, size_t len)

    # TLV iterators
    bool attr_ok "mnl_attr_ok" (const netlink.Nlattr *attr, int len)
    netlink.Nlattr * attr_next "mnl_attr_next" (const netlink.Nlattr *attr)

    # TLV callback-based attribute parsers
    # ctypedef int (*mnl_attr_cb_t)(const netlink.Nlattr *attr, void *data)
    struct attr_cb_t "mnl_attr_cb_t":
        pass

    int attr_parse "mnl_attr_parse" (const netlink.Nlmsghdr *nlh, unsigned int offset, attr_cb_t cb, void *data)
    int attr_parse_nested "mnl_attr_parse_nested" (const netlink.Nlattr *attr, attr_cb_t cb, void *data)
    int attr_parse_payload "mnl_attr_parse_payload" (const void *payload, size_t payload_len, attr_cb_t cb, void *data)

    #
    # callback API
    #
    enum: MNL_CB_ERROR
    enum: MNL_CB_STOP
    enum: MNL_CB_OK

    # ctypedef int (*mnl_cb_t)(const netlink.Nlmsghdr *nlh, void *data)
    struct cb_t "mnl_cb_t":
        pass

    int cb_run "mnl_cb_run" (const void *buf, size_t numbytes, unsigned int seq,
                             unsigned int portid, cb_t cb_data, void *data)

    int cb_run2 "mnl_cb_run2" (const void *buf, size_t numbytes, unsigned int seq,
                               unsigned int portid, cb_t cb_data, void *data,
                               cb_t *cb_ctl_array, unsigned int cb_ctl_array_len)

    #
    # other declarations
    #
    enum: SOL_NETLINK

    # XXX: MNL_ARRAY_SIZE

"""
Generators are only supported in def functions.
XXX: I have no idea without yield...

cdef mnl_attr_for_each(netlink.Nlmsghdr *nlh, size_t offset):
    cdef netlink.Nlattr *attr = <netlink.Nlattr *>mnl_nlmsg_get_payload_offset(nlh, offset)
    while mnl_attr_ok(attr, <char *>mnl_nlmsg_get_payload_tail(nlh) - <char *>(attr)):
        yield attr
        attr = mnl_attr_next(attr)

cdef mnl_attr_for_each_nested(netlink.Nlattr *nest):
    cdef netlink.Nlattr *attr = <netlink.Nlattr *>mnl_attr_get_payload(nest)
    while mnl_attr_ok(attr, <char *>mnl_attr_get_payload(nest) + mnl_attr_get_payload_len(next) - <char *>(attr)):
        yield attr
        attr = mnl_attr_next(attr)

cdef mnl_attr_for_each_payload(void *payload, int payload_size):
    cdef netlink.Nlattr *attr = <netlink.Nlattr *>payload
    while mnl_attr_ok(attr, <char *>payload + payload_size - <char *>(attr)):
        yield attr
        attr = mnl_attr_next(attr)
"""

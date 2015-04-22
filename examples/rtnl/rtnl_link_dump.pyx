from libc.stdint cimport uint8_t
from libc.stdlib cimport exit, EXIT_SUCCESS, EXIT_FAILURE
from libc.stdio cimport perror, printf

cimport cylmnl as mnl
cimport cylmnl.linux.netlinkh as netlink
cimport cylmnl.linux.rtnetlinkh as rtnl
cimport cylmnl.linux.if_linkh as ifnl
cimport cylmnl.linux.ifh as ifh

cdef extern from "sys/socket.h":
    enum: AF_PACKET

cdef int data_attr_cb(const netlink.Nlattr *attr, void *data) nogil:
    cdef const netlink.Nlattr **tb = <netlink.Nlattr **>data
    cdef int attr_type = mnl.attr_get_type(attr)

    # skip unsupported attribute in user-space
    if mnl.attr_type_valid(attr, ifnl.IFLA_MAX) < 0:
        return mnl.MNL_CB_OK

    if attr_type == ifnl.IFLA_ADDRESS:
        if mnl.attr_validate(attr, mnl.MNL_TYPE_BINARY) < 0:
            perror("mnl_attr_validate")
            return mnl.MNL_CB_ERROR
    elif attr_type == ifnl.IFLA_MTU:
        if mnl.attr_validate(attr, mnl.MNL_TYPE_U32) < 0:
            perror("mnl_attr_validate")
            return mnl.MNL_CB_ERROR
    elif attr_type == ifnl.IFLA_IFNAME:
        if mnl.attr_validate(attr, mnl.MNL_TYPE_STRING) < 0:
            perror("mnl_attr_validate")
            return mnl.MNL_CB_ERROR

    tb[attr_type] = attr
    return mnl.MNL_CB_OK


cdef int data_cb(const netlink.Nlmsghdr *nlh, void *data) nogil:
    cdef netlink.Nlattr *tb[ifnl.IFLA_MAX + 1] # = {}
    cdef rtnl.Ifinfomsg *ifm = <rtnl.Ifinfomsg *>mnl.nlmsg_get_payload(nlh)
    cdef uint8_t *hwaddr
    cdef int i

    # XXX:
    for i in range(ifnl.IFLA_MAX): tb[i] = NULL

    printf("index=%d type=%d family=%d ",
           ifm.ifi_index, ifm.ifi_type, ifm.ifi_flags, ifm.ifi_family)

    if ifm.ifi_flags & ifh.IFF_RUNNING:
        printf("[RUNNING] ")
    else:
        printf("[NOT RUNNING] ")

    # can use starred expression only as assignment target
    mnl.attr_parse(nlh, sizeof(rtnl.Ifinfomsg), <mnl.attr_cb_t>data_attr_cb, tb)
    if tb[ifnl.IFLA_MTU] != NULL:
        printf("mtu=%d ", mnl.attr_get_u32(tb[ifnl.IFLA_MTU]))
    if tb[ifnl.IFLA_IFNAME] != NULL:
        printf("name=%s ", mnl.attr_get_str(tb[ifnl.IFLA_IFNAME]))
    if tb[ifnl.IFLA_ADDRESS] != NULL:
        # cdef statement not allowed here
        # cdef uint8_t *hwaddr = mnl.attr_get_payload(tb[ifnl.IFLA_ADDRESS])

        hwaddr = <uint8_t *>mnl.attr_get_payload(tb[ifnl.IFLA_ADDRESS])
        printf("hwaddr=")
        for i in range(mnl.attr_get_payload_len(tb[ifnl.IFLA_ADDRESS])):
            printf("%.2x", hwaddr[i] & 0xff)
            if (i+1 != mnl.attr_get_payload_len(tb[ifnl.IFLA_ADDRESS])):
                printf(":")

    printf("\n")
    return mnl.MNL_CB_OK


cdef int main() nogil:
    cdef mnl.Socket *nl
    cdef char buf[mnl.MNL_SOCKET_BUFFER_SIZE]
    cdef netlink.Nlmsghdr *nlh
    cdef rtnl.Rtgenmsg *rt
    cdef int ret
    cdef unsigned int seq, portid

    nlh = mnl.nlmsg_put_header(&buf[0])
    nlh.nlmsg_type = rtnl.RTM_GETLINK
    nlh.nlmsg_flags = netlink.NLM_F_REQUEST | netlink.NLM_F_DUMP
    nlh.nlmsg_seq = seq = 123 # time(NULL)
    rt = <rtnl.Rtgenmsg *>mnl.nlmsg_put_extra_header(nlh, sizeof(rtnl.Rtgenmsg))
    rt.rtgen_family = AF_PACKET

    nl = mnl.socket_open(netlink.NETLINK_ROUTE)
    if nl == NULL:
        perror("mnl_socket_open")
        exit(EXIT_FAILURE)

    if mnl.socket_bind(nl, 0, mnl.MNL_SOCKET_AUTOPID) < 0:
        perror("mnl_socket_bind")
        exit(EXIT_FAILURE)

    portid = mnl.socket_get_portid(nl)

    if mnl.socket_sendto(nl, nlh, nlh.nlmsg_len) < 0:
        perror("mnl_socket_sendto")
        exit(EXIT_FAILURE)

    ret = mnl.socket_recvfrom(nl, &buf[0], sizeof(buf))
    while ret > 0:
        ret = mnl.cb_run(&buf[0], ret, seq, portid, <mnl.cb_t>data_cb, NULL)
        if ret <= mnl.MNL_CB_STOP:
            break
        ret = mnl.socket_recvfrom(nl, &buf[0], sizeof(buf))

    if ret == -1:
        perror("error")
        exit(EXIT_FAILURE)

    mnl.socket_close(nl)

    return 0

if __name__ == "__main__":
    with nogil:
        main()

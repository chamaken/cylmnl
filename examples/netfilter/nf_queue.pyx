from libc.stdint cimport uint8_t, uint16_t, uint32_t
from libc.stdlib cimport exit, atoi, EXIT_SUCCESS, EXIT_FAILURE
from libc.stdio cimport perror, printf

cimport cylmnl as mnl
cimport cylmnl.linux.netlinkh as netlink
cimport cylmnl.linux.netfilterh as nf
cimport cylmnl.linux.netfilter.nfnetlinkh as nfnl
cimport cylmnl.linux.netfilter.nfnetlink_queueh as nfqnl


cdef extern from "arpa/inet.h" nogil:
    cdef uint32_t ntohl(uint32_t netlong)
    cdef uint32_t htonl(uint32_t hostlong)
    cdef uint16_t ntohs(uint16_t netshort)
    cdef uint16_t htons(uint16_t hostshort)


cdef extern from "sys/socket.h" nogil:
    enum: AF_UNSPEC
    enum: AF_INET


cdef int parse_attr_cb(const netlink.Nlattr *attr, void *data) nogil:
    cdef const netlink.Nlattr **tb = <netlink.Nlattr **>data
    cdef int attr_type = mnl.attr_get_type(attr)

    if attr_type == nfqnl.NFQA_MARK \
            or attr_type == nfqnl.NFQA_IFINDEX_INDEV \
            or attr_type == nfqnl.NFQA_IFINDEX_OUTDEV \
            or attr_type == nfqnl.NFQA_IFINDEX_PHYSINDEV \
            or attr_type == nfqnl.NFQA_IFINDEX_PHYSOUTDEV:
        if mnl.attr_validate(attr, mnl.MNL_TYPE_U32) < 0:
            perror("mnl_attr_validate")
            return mnl.MNL_CB_ERROR
    elif attr_type == nfqnl.NFQA_TIMESTAMP:
        if mnl.attr_validate2(attr, mnl.MNL_TYPE_UNSPEC,
                              sizeof(nfqnl.NfqnlMsgPacketTimestamp)) < 0:
            perror("mnl_attr_validate2")
            return mnl.MNL_CB_ERROR
    elif attr_type == nfqnl.NFQA_HWADDR:
        if mnl.attr_validate2(attr, mnl.MNL_TYPE_UNSPEC,
                              sizeof(nfqnl.NfqnlMsgPacketHw)) < 0:
            perror("mnl_attr_validate2")
            return mnl.MNL_CB_ERROR
    elif attr_type == nfqnl.NFQA_PAYLOAD:
        pass

    tb[attr_type] = attr
    return mnl.MNL_CB_OK


cdef int queue_cb(const netlink.Nlmsghdr *nlh, void *data) nogil:
    cdef netlink.Nlattr *tb[nfqnl.NFQA_MAX + 1] # = {}
    cdef nfqnl.NfqnlMsgPacketHdr *ph = NULL
    cdef uint32_t packet_id = 0

    for i in range(nfqnl.NFQA_MAX): tb[i] = NULL

    mnl.attr_parse(nlh, sizeof(nfnl.Nfgenmsg), <mnl.attr_cb_t>parse_attr_cb, tb)
    if tb[nfqnl.NFQA_PACKET_HDR] != NULL:
        ph = <nfqnl.NfqnlMsgPacketHdr *>mnl.attr_get_payload(tb[nfqnl.NFQA_PACKET_HDR])
        packet_id = ntohl(ph.packet_id)
        printf("packet received (id=%u hw=0x%04x hook=%u)\n",
               packet_id, ntohs(ph.hw_protocol), ph.hook)

        return mnl.MNL_CB_OK + packet_id


cdef netlink.Nlmsghdr *nfq_build_cfg_pf_request(char *buf, uint8_t command) nogil:
    cdef netlink.Nlmsghdr *nlh = mnl.nlmsg_put_header(buf)
    nlh.nlmsg_type = (nfnl.NFNL_SUBSYS_QUEUE << 8) | nfqnl.NFQNL_MSG_CONFIG
    nlh.nlmsg_flags = netlink.NLM_F_REQUEST

    cdef nfnl.Nfgenmsg *nfg = <nfnl.Nfgenmsg *>mnl.nlmsg_put_extra_header(nlh, sizeof(nfnl.Nfgenmsg))
    nfg.nfgen_family = AF_UNSPEC
    nfg.version = nfnl.NFNETLINK_V0

    cdef nfqnl.NfqnlMsgConfigCmd cmd
    cmd.command = command
    cmd.pf = htons(AF_INET)

    mnl.attr_put(nlh, nfqnl.NFQA_CFG_CMD, sizeof(nfqnl.NfqnlMsgConfigCmd), &cmd)

    return nlh


cdef netlink.Nlmsghdr *nfq_build_cfg_request(char *buf, uint8_t command, int queue_num) nogil:
    cdef netlink.Nlmsghdr *nlh = mnl.nlmsg_put_header(buf)
    nlh.nlmsg_type = (nfnl.NFNL_SUBSYS_QUEUE << 8) | nfqnl.NFQNL_MSG_CONFIG
    nlh.nlmsg_flags = netlink.NLM_F_REQUEST

    cdef nfnl.Nfgenmsg *nfg = <nfnl.Nfgenmsg *>mnl.nlmsg_put_extra_header(nlh, sizeof(nfnl.Nfgenmsg))
    nfg.nfgen_family = AF_UNSPEC
    nfg.version = nfnl.NFNETLINK_V0
    nfg.res_id = htons(queue_num)

    cdef nfqnl.NfqnlMsgConfigCmd cmd
    cmd.command = command
    cmd.pf = htons(AF_INET)

    mnl.attr_put(nlh, nfqnl.NFQA_CFG_CMD, sizeof(nfqnl.NfqnlMsgConfigCmd), &cmd)

    return nlh


cdef netlink.Nlmsghdr *nfq_build_cfg_params(char *buf, uint8_t mode, int range, int queue_num) nogil:
    cdef netlink.Nlmsghdr *nlh = mnl.nlmsg_put_header(buf)
    nlh.nlmsg_type = (nfnl.NFNL_SUBSYS_QUEUE << 8) | nfqnl.NFQNL_MSG_CONFIG
    nlh.nlmsg_flags = netlink.NLM_F_REQUEST

    cdef nfnl.Nfgenmsg *nfg = <nfnl.Nfgenmsg *>mnl.nlmsg_put_extra_header(nlh, sizeof(nfnl.Nfgenmsg))
    nfg.nfgen_family = AF_UNSPEC
    nfg.version = nfnl.NFNETLINK_V0
    nfg.res_id = htons(queue_num)

    cdef nfqnl.NfqnlMsgConfigParams params
    params.copy_range = htonl(range)
    params.copy_mode = mode

    mnl.attr_put(nlh, nfqnl.NFQA_CFG_PARAMS, sizeof(nfqnl.NfqnlMsgConfigParams), &params)

    return nlh


cdef netlink.Nlmsghdr *nfq_build_verdict(char *buf, int packet_id, int queue_num, int verd) nogil:
    cdef netlink.Nlmsghdr *nlh
    cdef nfnl.Nfgenmsg *nfg

    nlh = mnl.nlmsg_put_header(buf)
    nlh.nlmsg_type = (nfnl.NFNL_SUBSYS_QUEUE << 8) | nfqnl.NFQNL_MSG_VERDICT
    nlh.nlmsg_flags = netlink.NLM_F_REQUEST
    nfg = <nfnl.Nfgenmsg *>mnl.nlmsg_put_extra_header(nlh, sizeof(nfnl.Nfgenmsg))
    nfg.nfgen_family = AF_UNSPEC
    nfg.version = nfnl.NFNETLINK_V0
    nfg.res_id = htons(queue_num)

    cdef nfqnl.NfqnlMsgVerdictHdr vh
    vh.verdict = htonl(verd)
    vh.id = htonl(packet_id)

    mnl.attr_put(nlh, nfqnl.NFQA_VERDICT_HDR, sizeof(nfqnl.NfqnlMsgVerdictHdr), &vh)

    return nlh


cdef int main(int argc, char *argv[]) nogil:
    cdef mnl.Socket *nl
    cdef char buf[mnl.MNL_SOCKET_BUFFER_SIZE]
    cdef netlink.Nlmsghdr *nlh
    cdef int ret
    cdef unsigned int portid, queue_num
    cdef uint32_t packet_id

    if argc != 2:
        printf("Usage: %s [queue_num]\n", argv[0])
        exit(EXIT_FAILURE)

    queue_num = atoi(argv[1])

    nl = mnl.socket_open(netlink.NETLINK_NETFILTER)
    if nl == NULL:
        perror("mnl_socket_open")
        exit(EXIT_FAILURE)

    if mnl.socket_bind(nl, 0, mnl.MNL_SOCKET_AUTOPID) < 0:
        perror("mnl_socket_bind")
        exit(EXIT_FAILURE)

    portid = mnl.socket_get_portid(nl)

    nlh = nfq_build_cfg_pf_request(buf, nfqnl.NFQNL_CFG_CMD_PF_UNBIND)
    if mnl.socket_sendto(nl, nlh, nlh.nlmsg_len) < 0:
        perror("mnl_socket_sendto")
        exit(EXIT_FAILURE)

    nlh = nfq_build_cfg_pf_request(buf, nfqnl.NFQNL_CFG_CMD_PF_BIND)
    if mnl.socket_sendto(nl, nlh, nlh.nlmsg_len) < 0:
        perror("mnl_socket_sendto")
        exit(EXIT_FAILURE)

    nlh = nfq_build_cfg_request(buf, nfqnl.NFQNL_CFG_CMD_BIND, queue_num)
    if mnl.socket_sendto(nl, nlh, nlh.nlmsg_len) < 0:
        perror("mnl_socket_sendto")
        exit(EXIT_FAILURE)

    nlh = nfq_build_cfg_params(buf, nfqnl.NFQNL_COPY_PACKET, 0xFFFF, queue_num)
    if mnl.socket_sendto(nl, nlh, nlh.nlmsg_len) < 0:
        perror("mnl_socket_sendto")
        exit(EXIT_FAILURE)

    ret = mnl.socket_recvfrom(nl, buf, sizeof(buf))
    if ret == -1:
        perror("mnl_socket_recvfrom")
        exit(EXIT_FAILURE)

    while (ret > 0):
        # cdef statement not allowed here
        # cdef uint32_t packet_id

        ret = mnl.cb_run(buf, ret, 0, portid, <mnl.cb_t>queue_cb, NULL)
        if ret < 0:
            perror("mnl_cb_run")
            exit(EXIT_FAILURE)

        packet_id = ret - mnl.MNL_CB_OK
        nlh = nfq_build_verdict(buf, packet_id, queue_num, nf.NF_ACCEPT)
        if mnl.socket_sendto(nl, nlh, nlh.nlmsg_len) < 0:
            perror("mnl_socket_sendto")
            exit(EXIT_FAILURE)

        ret = mnl.socket_recvfrom(nl, buf, sizeof(buf))
        if ret == -1:
            perror("mnl_socket_recvfrom")
            exit(EXIT_FAILURE)

    mnl.socket_close(nl)

    return 0


# really? there must be more efficient way
cdef extern from "alloca.h" nogil:
    void *alloca(size_t size);

import sys
cdef int argc = len(sys.argv)
cdef char **argv = <char **>alloca(sizeof(char *) * argc)
for i, s in enumerate(sys.argv):
    argv[i] = s

if __name__ == "__main__":
    with nogil:
        main(argc, argv)

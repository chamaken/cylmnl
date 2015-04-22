cdef extern from "linux/if.h":
    # IFF_ only
    enum NetDeviceFlags:
        IFF_UP           # sysfs
        IFF_BROADCAST    # volatile
        IFF_DEBUG        # sysfs
        IFF_LOOPBACK     # volatile
        IFF_POINTOPOINT  # volatile
        IFF_NOTRAILERS   # sysfs
        IFF_RUNNING      # volatile
        IFF_NOARP        # sysfs
        IFF_PROMISC      # sysfs
        IFF_ALLMULTI     # sysfs
        IFF_MASTER       # volatile
        IFF_SLAVE        # volatile
        IFF_MULTICAST	 # sysfs
        IFF_PORTSEL      # sysfs
        IFF_AUTOMEDIA    # sysfs
        IFF_DYNAMIC      # sysfs
        IFF_LOWER_UP     # volatile
        IFF_DORMANT      # volatile
        IFF_ECHO         # volatile
        IFF_VOLATILE

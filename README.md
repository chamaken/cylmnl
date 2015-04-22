cylmnl
========

Cython wrapper of libmnl, just to satisfy my curiosity.

My impression is cdef extern libc is troublesome, but the way I use might be wrong.

sample
------

see examples

installation
------------

Only copying .pxd files to proper dir, I think. Or

    $ python setup.py install
    $ cd examples/rtnl
    $ make
    $ ./rtnl_link_dump

requires
--------

* libmnl
* Cython >= 0.19 ? (debian wheezy)

links
-----

* libmnl: http://netfilter.org/projects/libmnl/

from C to Cython
----------------

* add ``h'' to header file name.

* struct / enum name is converted ... like my_c_sample to MyCSample

* tried to keep remain original struct member name, but a few could
  not because of reserved word (like ``to'')

memo
----

cdef array in function is not cleared? see tb[] in example

comparison
----------

could not implement:

* mnl_attr_for_each_nested
* mnl_attr_for_each
* mnl_attr_for_each_payload

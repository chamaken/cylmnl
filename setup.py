from setuptools import setup

import os
from setuptools import setup

def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

setup(name='cylmnl',
      version='0.1',
      description='libmnl Cython wrapper',
      author='Ken-ichirou MATSUZAWA',
      author_email='chamas@h4.dion.ne.jp',
      url='https://github.com/chamaken/cylmnl',
      license='LGPLv2+',
      packages=['cylmnl', 'cylmnl.linux', 'cylmnl.linux.netfilter'],
      classifiers=['License :: OSI Approved :: GNU Lesser General ' +
                   'Public License v2 or later (LGPLv2+)',
                   'Programming Language :: Cython',
                   'Topic :: Software Development :: Libraries :: ' +
                   'Cython pxd declarations',
                   'Operating System :: Linux',
                   'Intended Audience :: Developers',
                   'Development Status :: 2 - Pre-Alpha'],

      data_files=[
        ('.',
         ['cylmnl/cylmnl.pxd',]),
        ('cylmnl/linux',
         ['cylmnl/linux/netlinkh.pxd',
          'cylmnl/linux/rtnetlinkh.pxd',
          'cylmnl/linux/ifh.pxd',
          'cylmnl/linux/if_linkh.pxd',
          'cylmnl/linux/netfilterh.pxd',
          ]),
        ('cylmnl/linux/netfilter',
         ['cylmnl/linux/netfilter/nfnetlinkh.pxd',
          'cylmnl/linux/netfilter/nfnetlink_compath.pxd',
          'cylmnl/linux/netfilter/nf_conntrack_commonh.pxd',
          'cylmnl/linux/netfilter/nfnetlink_queueh.pxd',
          'cylmnl/linux/netfilter/nfnetlink_conntrackh.pxd',
          ]),
        ],
      long_description=read('README.md'),
      # no test
      )

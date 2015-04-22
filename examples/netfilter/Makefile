# Makefile for creating our standalone Cython program
# refer: cython/Demos/embed/Makefile

PYTHON := python
CYTHON := cython
PYVERSION := $(shell $(PYTHON) -c "import sys; print(sys.version[:3])")

INCDIR := $(shell $(PYTHON) -c "from distutils import sysconfig; print(sysconfig.get_python_inc())")
PLATINCDIR := $(shell $(PYTHON) -c "from distutils import sysconfig; print(sysconfig.get_python_inc(plat_specific=True))")
LIBDIR1 := $(shell $(PYTHON) -c "from distutils import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")
LIBDIR2 := $(shell $(PYTHON) -c "from distutils import sysconfig; print(sysconfig.get_config_var('LIBPL'))")
PYLIB := $(shell $(PYTHON) -c "from distutils import sysconfig; print(sysconfig.get_config_var('LIBRARY')[3:-2])")

CC := $(shell $(PYTHON) -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('CC'))")
CXX := $(shell $(PYTHON) -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('CXX'))")
LINKCC := $(shell $(PYTHON) -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('LINKCC'))")
LINKFORSHARED := $(shell $(PYTHON) -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('LINKFORSHARED'))")
LIBS := $(shell $(PYTHON) -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('LIBS'))")
SYSLIBS :=  $(shell $(PYTHON) -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('SYSLIBS'))")
CXXFLAGS := -std=c++11

LIBS += -lmnl -lstdc++
TARGET := nf_queue nfct_daemon


.SUFFIXES: .pyx .ppyx
.PHONY: clean

.pyx.c:
	$(CYTHON) --embed $<

.ppyx.cpp:
	$(CYTHON) --cplus --embed $<

.c.o:
	$(CC) -c $^ -I$(INCDIR) -I$(PLATINCDIR)

.cpp.o:
	$(CXX) $(CXXFLAGS) -c $^ -I$(INCDIR) -I$(PLATINCDIR)

%: %.o
	$(LINKCC) -o $@ $^ -L$(LIBDIR1) -L$(LIBDIR2) -l$(PYLIB) $(LIBS) $(SYSLIBS) $(LINKFORSHARED)


all: $(TARGET)

clean:
	rm -rf *~ *.o *.so core core.* *.c *.cpp build dist $(TARGET)

CXX = g++
CFLAGS = -D_GNU_SOURCE -W -Wall -pipe -D_POSIX_PTHREAD_SEMANTICS -D_POSIX_THREADS -D_POSIX_THREAD_SAFE_FUNCTIONS -D_REENTRANT -DPDL_HAS_AIO_CALLS -m64 -mtune=k8 -O3 -funroll-loops -fno-strict-aliasing -fno-omit-frame-pointer -DPDL_NDEBUG -D_GNU_SOURCE -DACP_CFG_COMPILE_64BIT -DACP_CFG_COMPILE_BIT=64 -DACP_CFG_COMPILE_BIT_STR=64

INCLUDE+=-I./ -I./include -I${ALTIBASE_HOME}/include
ODBCLIB=/usr/local/lib

LFLAG = -Wl,-relax -Wl,--no-as-needed -L. -O3 -L$(ALTIBASE_HOME)/lib -L$(ODBCLIB)
LIBS = -ldl -lpthread -lcrypt -lrt -lstdc++ -lodbc

SOURCES = demo_ex1.cpp
OBJECTS = $(SOURCES:.cpp=.o)

EXEC  = demo_ex1

all: $(EXEC)

$(EXEC): $(OBJECTS)
	$(CXX) -o $@ $(OBJECTS) $(INCLUDE) $(LFLAG) $(LIBS)

.cpp.o :
	$(CXX) $(CFLAGS) -c $< $(INCLUDE)
clean:
	rm -f $(EXEC) *.o

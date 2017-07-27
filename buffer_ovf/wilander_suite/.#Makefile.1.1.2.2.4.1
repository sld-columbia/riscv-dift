CC=${TOOLCHAIN}/bin/gcc
INCLUDES=-I${STRATA}/include
PROTO2_OBJS=rev_memcpy.o dynamic_testbed_john_wilander.nicecap.o
PROTO2_SRCS=rev_memcpy.c dynamic_testbed.john_wilander.nicecap.c
PROTO2_LIBS=${STRATA}/lib/x86_linux/libstrata_normal.a

# adding new suffixes
.SUFFIXES: .stratafied .ncexe


wilander_tests.with_strata.proto2: .PHONY wilander_tests.with_strata.proto2.ncexe wilander_tests.with_strata.proto2.stratafied
	@echo $@ built

%.stratafied:  %.ncexe $(PROTO2_LIBS)
	${STRATA_HOME}/tools/stratafier/do_stratafy.sh $<
	 mv new.exe $@
	${NICECAP_HOME}/generate_exe.sh $(basename $@) $@ $< $<.annot

%.ncexe: $(PROTO2_OBJS)
	$(CC) -Bstatic -static $(PROTO2_OBJS) -o $@
	${SMPSA_HOME}/SMP-analyze.sh $@
	@if [ ! -f $@.annot ]; then echo Failed to generate annotations file; exit 1; fi 

wilander_tests.with_strata.proto2.o: $(PROTO2_SRCS)
	#$(CC) -O3 $(PROTO2_SRCS) -c $(INCLUDES) 
	$(CC) -g $(PROTO2_SRCS) -c $(INCLUDES) 

wilander_tests.no_strata: $(PROTO2_OBJS)
	$(CC) -Bstatic -static $(PROTO2_OBJS) -o $@

$(PROTO2_SRCS) $(DEFAULT_SRCS): rev_memcpy.h

.PHONY: env_check chopzero

# The generic rule for getting a .o file
.c.o:
	#$(CC) -O3 $< -c $(INCLUDES)
	$(CC) -g -O0 $< -c $(INCLUDES)

chopzero:
	@ if [ ! -f ${NICECAP_HOME}/chopzero ]; then gcc ${NICECAP_HOME}/chopzero.c -o ${NICECAP_HOME}/chopzero -O3 ; fi

env_check:
	@echo checking env vars; \
	if [ "X${TOOLCHAIN}" = "X" ]; then \
		echo TOOLCHAIN environment variable should be set.; \
		exit -1;\
	elif [ "X${STRATA}" = "X" ]; then \
		echo STRATA environment variable should be set. ;\
		exit -1;\
	elif [ "X${DIABLO_HOME}" = "X" ]; then \
		echo DIABLO_HOME environment variable should be set.; \
		exit -1;\
	elif [ "X${NICECAP_HOME}" = "X" ]; then \
		echo NICECAP_HOME environment variable should be set.; \
		exit -1;\
	elif [ "X${STRATA_HOME}" = "X" ]; then \
		echo STRATA_HOME environment variable should be set.; \
		exit -1;\
	fi ;

clean:
	rm -f wilander_tests.with_strata* wilander_tests.no_strata* *.o *.list *.map *.dis *-*isr *.asm *.exe

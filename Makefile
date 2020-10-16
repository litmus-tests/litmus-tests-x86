gen-tests: gen-basic-tests gen-extra-tests tests/non-mixed-size/CO/@all
	$(MAKE) tests/non-mixed-size/@all
.PHONY: gen-tests

tests/non-mixed-size/@all:
	cd $(dir $@) && ls -1 */@all > $(notdir $@)

### Basic tests ###############################################################

tests/non-mixed-size/BASIC_2_THREAD/@all: SIZE = 4
tests/non-mixed-size/BASIC_3_THREAD/@all: SIZE = 6
tests/non-mixed-size/BASIC_4_THREAD/@all: SIZE = 8
tests/non-mixed-size/BASIC_%_THREAD/@all: basic.conf
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	diy7 -conf $< -nprocs $* -eprocs -size $(SIZE) -o $(dir $@)

gen-basic-tests: tests/non-mixed-size/BASIC_2_THREAD/@all
gen-basic-tests: tests/non-mixed-size/BASIC_3_THREAD/@all
gen-basic-tests: tests/non-mixed-size/BASIC_4_THREAD/@all
.PHONY: gen-basic-tests

### Extra tests ###############################################################

tests/non-mixed-size/BASIC_2_THREAD_EXTRA/@all: SIZE = 8
tests/non-mixed-size/BASIC_3_THREAD_EXTRA/@all: SIZE = 12
tests/non-mixed-size/BASIC_4_THREAD_EXTRA/@all: SIZE = 16
# Generate basic tests first, so we can exclude them from extra
tests/non-mixed-size/BASIC_%_THREAD_EXTRA/@all: extra.conf tests/non-mixed-size/BASIC_%_THREAD/@all
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
# extract the cycles of basic tests, and pass them to diy so it doesn't generate them again
	mcycles7 $(word 2,$^) | sed 's/.*: //' > $(dir $@)/exclude_cycles.tmp
	diy7 -conf $< -nprocs $* -eprocs -size $(SIZE) -no $(dir $@)/exclude_cycles.tmp -o $(dir $@)
	rm -f $(dir $@)/exclude_cycles.tmp

gen-extra-tests: tests/non-mixed-size/BASIC_2_THREAD_EXTRA/@all
gen-extra-tests: tests/non-mixed-size/BASIC_3_THREAD_EXTRA/@all
gen-extra-tests: tests/non-mixed-size/BASIC_4_THREAD_EXTRA/@all
.PHONY: gen-extra-tests

### Coherence tests ###########################################################

tests/non-mixed-size/CO/@all:
	rm -rf $(dir $@) $(dir $@)_temp
	mkdir -p $(dir $@) $(dir $@)_temp
	diy7 -conf coherence.conf -o $(dir $@)_temp
	herd7 -model uniproc.cat $(dir $@)_temp/@all > $(dir $@)_temp/herd.log
	mlog2cond7 -forall true -optcond true < $(dir $@)_temp/herd.log > $(dir $@)_temp/conds.txt
	recond7 -toexists true -conds $(dir $@)_temp/conds.txt -o $(dir $@) $(dir $@)_temp/@all
	rm -rf $(dir $@)_temp
# Add CO-SBI
	diyone7 -arch X86_64 -type uint64_t -cond unicond -name CO-SBI Rfi PosRR Fre Rfi PosRR Fre
	mv CO-SBI.litmus $(dir $@)
	echo "CO-SBI.litmus" >> $@
# Add CoRR1
	diyone7 -arch X86_64 -type uint64_t -cond unicond -name CoRR1 Rfe PosRR Fre
	mv CoRR1.litmus $(dir $@)
	echo "CoRR1.litmus" >> $@
# Add CoRW
	diyone7 -arch X86_64 -type uint64_t -cond unicond -name CoRW PosRW Wse Rfe
	mv CoRW.litmus $(dir $@)
	echo "CoRW.litmus" >> $@
# Add CoWR
	diyone7 -arch X86_64 -type uint64_t -cond unicond -name CoWR PosWR Fre Wse
	mv CoWR.litmus $(dir $@)
	echo "CoWR.litmus" >> $@

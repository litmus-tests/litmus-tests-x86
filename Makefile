gen-tests:
	$(MAKE) tests/non-mixed-size/@all
.PHONY: gen-tests

tests/non-mixed-size/@all: $(wildcard tests/non-mixed-size/*/@all)
	cd $(dir $@) && ls -1 */@all > $(notdir $@)

### Basic tests ###############################################################

gen-tests: $(foreach n,2 3 4,tests/non-mixed-size/BASIC_$n_THREAD/@all)

tests/non-mixed-size/BASIC_%_THREAD/@all: basic.conf
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	diy7 -conf $< -nprocs $* -eprocs -size $$((2 * $*)) -o $(dir $@)

### Extra tests ###############################################################

gen-tests: $(foreach n,2 3 4,tests/non-mixed-size/BASIC_$n_THREAD_EXTRA/@all)

# Generate basic tests first, so we can exclude them from extra
tests/non-mixed-size/BASIC_%_THREAD_EXTRA/@all: extra.conf tests/non-mixed-size/BASIC_%_THREAD/@all
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
# extract the cycles of basic tests, and pass them to diy so it doesn't generate them again
	mcycles7 $(word 2,$^) | sed 's/.*: //' > $(dir $@)/exclude_cycles.tmp
	diy7 -conf $< -nprocs $* -eprocs -size $$((4 * $*)) -no $(dir $@)/exclude_cycles.tmp -o $(dir $@)
	rm -f $(dir $@)/exclude_cycles.tmp

### Coherence tests ###########################################################

gen-tests: tests/non-mixed-size/CO/@all

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

### Relax tests ###############################################################

gen-tests: $(foreach n,2 3,tests/non-mixed-size/RELAX_$n_THREAD/@all)

tests/non-mixed-size/RELAX_2_THREAD/@all: MODE = ppo
tests/non-mixed-size/RELAX_3_THREAD/@all: MODE = sc
# tests/non-mixed-size/RELAX_4_THREAD/@all: MODE = sc
tests/non-mixed-size/RELAX_%_THREAD/@all: relax.conf
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	diy7 -conf $< -nprocs $* -eprocs -size $$((3 * $*)) -mode $(MODE) -o $(dir $@)

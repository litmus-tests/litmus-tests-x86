# litmus-tests-x86

This litmus-tests-x86 repository contains a modest set of litmus tests
for x86, principally for those learning about relaxed-memory concurrency.
It only exercises some of the basics: loads, stores, and mfences. 

These litmus tests have been automatically generated using the
diy7 and diyone test generators from the diy tool suite <http://diy.inria.fr>.
The tests are in the form used both by that
tool suite (which also includes the litmus tool for running tests on
hardware and the herd tool for running tests in axiomatic models) and
by the rmem tool <http://www.cl.cam.ac.uk/users/pes20/rmem>, for
running tests in operational models.

The tests are distributed subject to the BSD 2-clause licence in
LICENCE.

This work has been partly supported by the ERC Advanced Grant ELVER, 789108.


People
======

The contributors are Shaked Flur and Peter Sewell


Links
=====

* [The REMS project](https://www.cl.cam.ac.uk/~pes20/rems/)

* [Web interface of the rmem tool](https://www.cl.cam.ac.uk/~pes20/rmem/)

* [The diy tool suite (including diy, litmus, and herd)](http://diy.inria.fr/)



Files
=====

* LICENCE - Licence

* Makefile - For running hardware tests and comparing results (see below)

* riscv.cfg - A litmus configuration file (used by Makefile)

* README.md - This file

* tests - Each test is in a separate .litmus file.  Files in sub-folders
with a build.sh script were generated by running the script.  Files in
sub-folders with an X.conf file (and no build.sh script) were
generated by running 'diy7 -conf X.conf'.




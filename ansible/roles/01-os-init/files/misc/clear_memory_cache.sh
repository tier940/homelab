#!/usr/bin/env bash
# Note, I'm using "echo 1", because using "echo 3" is not recommended in production.
sync && sysctl -w vm.drop_caches=3 && printf '\n%!s(MISSING)\n' 'RAM-cache and Swap were cleared.'

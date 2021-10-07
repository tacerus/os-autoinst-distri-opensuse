# SLE12 online migration tests
#
# Copyright 2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Package: SUSEConnect zypper yast2-registration
# Summary: sle12 online migration testsuite
# Maintainer: yutao <yuwang@suse.com>

use base "y2_module_consoletest";
use strict;
use warnings;
use testapi;
use migration;

sub run {
    select_console 'root-console';
    register_system_in_textmode;
}

sub test_flags {
    return {fatal => 1};
}

1;

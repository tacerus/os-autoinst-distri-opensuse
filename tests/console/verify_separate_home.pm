# SUSE's openQA tests
#
# Copyright 2019-2021 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved. This file is offered as-is,
# without any warranty.

# Package: util-linux
# Summary: Verification module. Asserts if /home located on the separate
# partition/volume.
# Maintainer: QE YaST <qa-sle-yast@suse.de>

use base "consoletest";
use strict;
use warnings FATAL => 'all';
use testapi;

sub run {
    select_console 'root-console';

    assert_script_run("lsblk -n | grep '/home'",
        fail_message => "Fail!\n
        Expected: /home is on separate partition/volume.\n
        Actual: /home is NOT on separate partition/volume."
    );
}

1;

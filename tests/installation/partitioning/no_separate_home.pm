# SUSE's openQA tests
#
# Copyright 2019-2021 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved. This file is offered as-is,
# without any warranty.

# Summary: The test module goes through the Suggested Partitioning wizard,
# keeping all the default values but explicitly disables separate /home
# partition.
# Maintainer: QE YaST <qa-sle-yast@suse.de>

use parent 'y2_installbase';
use strict;
use warnings FATAL => 'all';
use testapi;

sub run {
    my $partitioner    = $testapi::distri->get_partitioner();
    my $multiple_disks = get_var('NUMDISKS', 1) > 1 ? 1 : 0;
    $partitioner->edit_proposal(has_separate_home => 0, multiple_disks => $multiple_disks);
}

1;

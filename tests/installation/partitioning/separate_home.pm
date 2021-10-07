# SUSE's openQA tests
#
# Copyright 2019-2021 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved. This file is offered as-is,
# without any warranty.

# Summary: The test module goes through the Suggested Partitioning wizard,
# keeping all the default values but explicitly enables separate /home
# partition.
# Maintainer: QE YaST <qa-sle-yast@suse.de>

use parent 'y2_installbase';
use strict;
use warnings FATAL => 'all';

sub run {
    my $partitioner = $testapi::distri->get_partitioner();
    $partitioner->edit_proposal(has_separate_home => 1);
}

1;

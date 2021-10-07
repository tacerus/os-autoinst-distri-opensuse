# Copyright 2019-2021 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, see <http://www.gnu.org/licenses/>.
#
# Summary: Test EVM protection using digital signatures
# Note: This case should come after 'evm_protection_hmacs'
# Maintainer: llzhao <llzhao@suse.com>
# Tags: poo#53582, poo#92347

use base "opensusebasetest";
use strict;
use warnings;
use testapi;
use utils;
use bootloader_setup "replace_grub_cmdline_settings";
use power_action_utils "power_action";

sub run {
    my ($self) = @_;
    $self->select_serial_terminal;

    my $fstype     = 'ext4';
    my $sample_app = '/usr/bin/yes';
    my $sample_cmd = 'yes --version';

    my $mok_priv = '/root/certs/key.asc';
    my $mok_pass = 'suse';

    # Execute additional chattr -i '{}' before evmctl sign as a workaround
    # for find command issue which always execute the signing and "chattr +i"
    # command twice.
    my @sign_cmd = (
        "/usr/bin/find / -fstype $fstype -type f -executable -uid 0 -exec evmctl sign -p$mok_pass -k $mok_priv '{}' \\;",
"for D in /lib /lib64 /usr/lib /usr/lib64; do /usr/bin/find \"\$D\" -fstype $fstype -\\! -executable -type f -name '*.so*' -uid 0 -exec chattr -i '{}' \\; -exec evmctl sign -p$mok_pass -k $mok_priv '{}' \\; -exec chattr +i '{}' \\; ; done",
"/usr/bin/find /lib/modules -fstype $fstype -type f -name '*.ko' -uid 0 -exec chattr -i '{}' \\; -exec evmctl sign -p$mok_pass -k $mok_priv '{}' \\; -exec chattr +i '{}' \\;",
"/usr/bin/find /lib/firmware -fstype $fstype -type f -uid 0 -exec chattr -i '{}' \\; -exec evmctl sign -p$mok_pass -k $mok_priv '{}' \\; -exec chattr +i '{}' \\;"
    );

    for my $s (@sign_cmd) {
        my $findret = script_output($s, 1800, proceed_on_failure => 1);

        # Allow "No such file" message for the files in /proc because they are mutable
        my @finds = split /\n/, $findret;
        foreach my $f (@finds) {
            $f =~ m/\/proc\/.*No such file|name|uuid|generation|no xattr|hash|evm\/ima signature|^\w{530}$/ or die "Failed to create security.evm for $f";
        }
    }

    validate_script_output "getfattr -m . -d $sample_app", sub {
        # Base64 armored security.evm and security.ima content (50 chars), we
        # do not match the last three ones here for simplicity
        m/security\.evm=[0-9a-zA-Z+\/]{355}.*
          security\.ima=[0-9a-zA-Z+\/]{47}/sxx;
    };

    assert_script_run "chattr -i $sample_app";
    assert_script_run "setfattr -x security.evm $sample_app";
    validate_script_output "getfattr -m security.evm -d $sample_app", sub { m/^$/ };

    if (script_run("grep CONFIG_INTEGRITY_TRUSTED_KEYRING=y /boot/config-`uname -r`") == 0) {
        record_soft_failure("bsc#1157432 for SLE15SP2+: CA could not be loaded into the .ima or .evm keyring");
    }
    else {
        replace_grub_cmdline_settings('evm=fix ima_appraise=fix', '', update_grub => 1);
        power_action('reboot', textmode => 1);
        $self->wait_boot(textmode => 1);
        $self->select_serial_terminal;

        my $ret = script_output($sample_cmd, 30, proceed_on_failure => 1);
        die "$sample_app should not have permission to run" if ($ret !~ "\Q$sample_app\E: *Permission denied");
    }
}

sub test_flags {
    return {always_rollback => 1};
}

1;

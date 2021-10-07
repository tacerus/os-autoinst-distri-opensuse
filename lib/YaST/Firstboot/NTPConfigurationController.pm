# SUSE's openQA tests
#
# Copyright 2021 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved. This file is offered as-is,
# without any warranty.

# Summary: Controller for YaST Firstboot NTP Configuration
# Maintainer: QE YaST <qa-sle-yast@suse.de>

package YaST::Firstboot::NTPConfigurationController;
use strict;
use warnings;
use YuiRestClient;
use YaST::Firstboot::NTPConfigurationPage;

sub new {
    my ($class, $args) = @_;
    my $self = bless {}, $class;
    return $self->init($args);
}

sub init {
    my ($self, $args) = @_;
    $self->{NTPConfigurationPage} = YaST::Firstboot::NTPConfigurationPage->new({app => YuiRestClient::get_app()});
    return $self;
}

sub get_ntp_configuration_page {
    my ($self) = @_;
    die "NTP configuration page is not shown" unless $self->{NTPConfigurationPage}->is_shown();
    return $self->{NTPConfigurationPage};
}

sub proceed_with_current_configuration {
    my ($self) = @_;
    $self->get_ntp_configuration_page()->press_next();
}

1;

#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use OrionSOAP;

sub orionsoap {

    OrionSOAP->new()->test_xml_xs();
}

orionsoap();
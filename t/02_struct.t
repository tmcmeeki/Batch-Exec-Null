#!/usr/bin/perl
#
# 02_struct.t - test harness for the Batch::Exec::Null class: structures
#
use strict;

use Data::Dumper;
use Logfer qw/ :all /;
#use Log::Log4perl qw/ :easy /;
use Test::More tests => 61;

BEGIN { use_ok('Batch::Exec::Null') };


# -------- constants --------


# -------- global variables --------
my $log = get_logger(__FILE__);

my $cycle = 1;


# -------- subroutines --------


# -------- main --------
my $obn1 = Batch::Exec::Null->new(global => 0);
isa_ok($obn1, "Batch::Exec::Null",	"class check $cycle"); $cycle++;

my $obn2 = Batch::Exec::Null->new(null => "nil");
isa_ok($obn2, "Batch::Exec::Null",      "class check $cycle"); $cycle++;


# -------- Matches hash --------
my %data = ( 'aa' => 1, 'bb' => 'nil', 'cc' => undef, 'dd' => "" );

is($obn1->Matches("refh", 1, 'aa', \%data), 1,		"Matches hash integer");
is($obn1->Matches("refh", 'nil', 'bb', \%data), 1,	"Matches hash string");
is($obn1->Matches("refh", "", 'dd', \%data), 1,	"Matches hash blank");
is($obn1->Matches("refh", 'nil', 'ee', \%data), 0,	"Matches hash nokey");


# -------- Matches array --------
my @data = ( 1, 'nil', undef, "" );

is($obn1->Matches("refa", 1, 0, \@data), 1,	"Matches array integer");
is($obn1->Matches("refa", 'nil', 1, \@data), 1,	"Matches array string");
is($obn1->Matches("refa", "", 3, \@data), 1,	"Matches array blank");
is($obn1->Matches("refa", 'nil', 4, \@data), 0,	"Matches array noelement");

SKIP: {
        skip "syntax errors Matches", 2;

	is($obn1->Matches("refh", undef, 'cc', \%data), 1,	"Matches hash syntax");
	is($obn1->Matches("refa", undef, 2, \@data), 1,	"Matches array syntax");
}


# -------- is_null structures --------
is($obn2->is_null("aa", \%data), 0,		"is_null hash no");
is($obn2->is_null("bb", \%data), 1,		"is_null hash yes");
is($obn2->is_null("cc", \%data), 0,		"is_null hash undef warn");
is($obn2->is_null("dd", \%data), 0,		"is_null hash blank");
is($obn2->is_null("ee", \%data), 0,		"is_null hash dne");

is($obn2->is_null(0, \@data), 0,		"is_null array no");
is($obn2->is_null(1, \@data), 1,		"is_null array yes");
is($obn2->is_null(2, \@data), 0,		"is_null array undef warn");
is($obn2->is_null(3, \@data), 0,		"is_null array blank");
is($obn2->is_null(4, \@data), 0,		"is_null array dne");


# -------- negation: is_notnull and isnt_null --------
is($obn2->is_notnull("aa", \%data), 1,		"is_notnull hash no");
is($obn2->is_notnull("bb", \%data), 0,		"is_notnull hash yes");
is($obn2->is_notnull(0, \@data), 1,		"is_notnull array no");
is($obn2->is_notnull(1, \@data), 0,		"is_notnull array yes");

is($obn2->isnt_null("aa", \%data), 1,		"isnt_null hash no");
is($obn2->isnt_null("bb", \%data), 0,		"isnt_null hash yes");
is($obn2->isnt_null(0, \@data), 1,		"isnt_null array no");
is($obn2->isnt_null(1, \@data), 0,		"isnt_null array yes");


# -------- is_blank structures --------
is($obn2->is_blank("aa", \%data), 0,		"is_blank hash no");
is($obn2->is_blank("bb", \%data), 0,		"is_blank hash yes");
is($obn2->is_blank("cc", \%data), 0,		"is_blank hash undef warn");
is($obn2->is_blank("dd", \%data), 1,		"is_blank hash blank");
is($obn2->is_blank("ee", \%data), 0,		"is_blank hash dne");

is($obn2->is_blank(0, \@data), 0,		"is_blank array no");
is($obn2->is_blank(1, \@data), 0,		"is_blank array yes");
is($obn2->is_blank(2, \@data), 0,		"is_blank array undef warn");
is($obn2->is_blank(3, \@data), 1,		"is_blank array blank");
is($obn2->is_blank(4, \@data), 0,		"is_blank array dne");


# -------- negation: is_notblank and isnt_blank --------
is($obn1->is_notblank("aa", \%data), 1,		"is_notblank hash no");
is($obn1->is_notblank("dd", \%data), 0,		"is_notblank hash blank");
is($obn1->is_notblank(0, \@data), 1,		"is_notblank array no");
is($obn1->is_notblank(3, \@data), 0,		"is_notblank array blank");

is($obn1->isnt_blank("aa", \%data), 1,		"isnt_blank hash no");
is($obn1->isnt_blank("dd", \%data), 0,		"isnt_blank hash blank");
is($obn1->isnt_blank(0, \@data), 1,		"isnt_blank array no");
is($obn1->isnt_blank(3, \@data), 0,		"isnt_blank array blank");


# -------- nvl structures --------
is($obn2->nvl("aa", undef), "aa",		"nvl hash syntax okay");
SKIP: {
        skip "syntax errors nvl", 1;

	is($obn2->nvl("aa", "dummy"), $obn2->null,	"nvl hash syntax bad");
}
is($obn2->nvl("aa", \%data), 1,			"nvl hash integer");
is($obn2->nvl("bb", \%data), 'nil',		"nvl hash string");
is($obn2->nvl("cc", \%data), $obn2->null,	"nvl hash undef");
is($obn2->nvl("dd", \%data), $obn2->null,	"nvl hash blank");
is($obn2->nvl("ee", \%data), $obn2->null,	"nvl hash dne");

is($obn2->nvl(0, \@data), 1,			"nvl array integer");
is($obn2->nvl(1, \@data), 'nil',		"nvl array string");
is($obn2->nvl(2, \@data), $obn2->null,		"nvl array undef");
is($obn2->nvl(3, \@data), $obn2->null,		"nvl array blank");
is($obn2->nvl(4, \@data), $obn2->null,		"nvl array dne");


__END__

=head1 DESCRIPTION

02_struct.t - test harness for the Batch::Exec::Null class: structures

=head1 VERSION

_IDE_REVISION_

=head1 AUTHOR

B<Tom McMeekin> tmcmeeki@cpan.org

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published
by the Free Software Foundation; either version 2 of the License,
or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

=head1 SEE ALSO

L<perl>, L<Batch::Exec>.

=cut


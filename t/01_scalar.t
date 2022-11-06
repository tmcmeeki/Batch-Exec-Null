#!/usr/bin/perl
#
# 01_scalar.t - test harness for the Batch::Exec::Null class: scalars
#
use strict;

use Data::Dumper;
use Logfer qw/ :all /;
#use Log::Log4perl qw/ :easy /;
use Test::More tests => 52;

BEGIN { use_ok('Batch::Exec::Null') };


# -------- constants --------


# -------- global variables --------
my $log = get_logger(__FILE__);

my $cycle = 1;


# -------- subroutines --------


# -------- main --------
my $obn1 = Batch::Exec::Null->new;
isa_ok($obn1, "Batch::Exec::Null",	"class check $cycle"); $cycle++;

my $obn2 = Batch::Exec::Null->new(global => 0, null => "nil");
isa_ok($obn2, "Batch::Exec::Null",      "class check $cycle"); $cycle++;


# -------- Compare --------
is($obn1->Compare("main", "noop"), 1,		"Compare noop noargs");
is($obn1->Compare("main", "eq", "bb", "bb"), 1,	"Compare eq same");
is($obn1->Compare("main", "eq", "aa", "bb"), 0,	"Compare eq diff");

SKIP: {
        skip "syntax errors Compare", 3;

	is($obn1->Compare("main", "invalid"), 1,	"Compare syntax");
	is($obn1->Compare("main", "noop", "aa"), 1,	"Compare noop args");
	is($obn1->Compare("main", "eq", "aa", "bb", "cc"), 0,	"Compare eq trop");
}

my $reb = qr/bb/;
is($obn1->Compare("main", "like", "bb", $reb), 1,	"Compare like same");
is($obn1->Compare("main", "like", "aa", $reb), 0,	"Compare like diff");


# -------- Matches basic --------
SKIP: {
        skip "syntax errors Matches", 1;

	is($obn1->Matches("dummy", 1), 1,	"Matches syntax");
}

is($obn1->Matches("scalar", 1, 1), 1,	"Matches scalar");
is($obn1->fatal(0), 0,			"Matches set non-fatal");

is($obn1->Matches("dummy", 1, 1, 1), 0,	"Matches invalid reference");
is($obn1->fatal(1), 1,			"Matches reset fatal");


# -------- is_null scalars --------
is($obn1->is_null($obn1->null), 1,	"is_null definitive");
is($obn1->is_null(""), 0,		"is_null blank");
is($obn1->is_null("xxx"), 0,		"is_null string");
is($obn1->null("xxx"), "xxx",		"null override");
is($obn1->is_null("xxx"), 1,		"is_null override");

SKIP: {
        skip "syntax errors is_null", 1;

	is($obn1->is_null(undef), 0,		"is_null undef");
}


# -------- negation: is_notnull and isnt_null --------
is($obn1->is_notnull($obn1->null), 0,	"is_notnull definitive");
is($obn1->is_notnull(""), 1,		"is_notnull blank");
is($obn1->is_notnull("abc"), 1,		"is_notnull string");

is($obn1->isnt_null($obn1->null), 0,	"isnt_null definitive");
is($obn1->isnt_null(""), 1,		"isnt_null blank");
is($obn1->isnt_null("abc"), 1,		"isnt_null string");


# -------- is_blank scalars --------
is($obn1->is_blank(""), 1,		"is_blank empty");
is($obn1->is_blank(" "), 1,		"is_blank space");
is($obn1->is_blank("x"), 0,		"is_blank notempty");
SKIP: {
        skip "syntax errors is_blank", 1;

	is($obn1->is_blank(undef), 0,		"is_blank syntax");
}


# -------- negation: is_notblank and isnt_blank --------
is($obn1->is_notblank(""), 0,		"is_notblank empty");
is($obn1->is_notblank(" "), 0,		"is_notblank space");
is($obn1->is_notblank("x"), 1,		"is_notblank notempty");

is($obn1->isnt_blank(""), 0,		"isnt_blank empty");
is($obn1->isnt_blank(" "), 0,		"isnt_blank space");
is($obn1->isnt_blank("x"), 1,		"isnt_blank notempty");


# -------- nvl scalar --------
is($obn1->nvl, $obn1->null,		"nvl syntax $cycle"); $cycle++;
isnt($obn1->nvl, $obn2->nvl,		"nvl syntax $cycle"); $cycle++;

is($obn1->nvl(""), $obn1->null,		"nvl definitive $cycle"); $cycle++;
is($obn2->nvl(""), $obn2->null,		"nvl definitive $cycle"); $cycle++;

is($obn1->nvl("a"), "a",		"nvl string $cycle"); $cycle++;
is($obn2->nvl("a"), "a",		"nvl string $cycle"); $cycle++;
is($obn1->nvl("a"), $obn2->nvl("a"),	"nvl string match");

is($obn1->nvl($obn1->null), $obn1->null,	"nvl null $cycle"); $cycle++;
is($obn2->nvl($obn2->null), $obn2->null,	"nvl null $cycle"); $cycle++;
is($obn1->nvl($obn1->null), $obn2->nvl($obn1->null),	"nvl null same");
isnt($obn1->nvl($obn1->null), $obn2->nvl($obn2->null),	"nvl null differs");

is($obn1->nvl(undef), $obn1->null,	"nvl undef $cycle"); $cycle++;
is($obn2->nvl(undef), $obn2->null,	"nvl undef $cycle"); $cycle++;
isnt($obn1->nvl(undef), $obn2->nvl(undef),	"nvl undef differs");


__END__

=head1 DESCRIPTION

01_scalar.t - test harness for the Batch::Exec::Null class: scalars

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


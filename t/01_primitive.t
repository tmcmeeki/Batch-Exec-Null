#!/usr/bin/perl
#
# 01_primitive.t - test harness for the Batch::Exec::Null class: primitives
#
use strict;

use Data::Dumper;
use Logfer qw/ :all /;
#use Log::Log4perl qw/ :easy /;
use Test::More tests => 75;

BEGIN { use_ok('Batch::Exec::Null') };


# -------- constants --------


# -------- global variables --------
my $log = get_logger(__FILE__);

my $cycle = 1;


# -------- subroutines --------


# -------- main --------
my $obn1 = Batch::Exec::Null->new;
isa_ok($obn1, "Batch::Exec::Null",	"class check $cycle"); $cycle++;


# -------- Compare --------
#is($obn1->Compare("main", "invalid"), 1,	"Compare syntax");
is($obn1->Compare("main", "noop"), 1,		"Compare noop noargs");
#is($obn1->Compare("main", "noop", "aa"), 1,	"Compare noop args");

is($obn1->Compare("main", "eq", "bb", "bb"), 1,	"Compare eq same");
is($obn1->Compare("main", "eq", "aa", "bb"), 0,	"Compare eq diff");
#is($obn1->Compare("main", "eq", "aa", "bb", "cc"), 0,	"Compare eq trop");

my $reb = qr/bb/;
is($obn1->Compare("main", "like", "bb", $reb), 1,	"Compare like same");
is($obn1->Compare("main", "like", "aa", $reb), 0,	"Compare like diff");


# -------- Matches basic --------
#is($obn1->Matches("dummy", 1), 1,	"Matches syntax");

is($obn1->Matches("scalar", 1, 1), 1,	"Matches scalar");

is($obn1->fatal(0), 0,			"set non-fatal");

is($obn1->Matches("dummy", 1, 1, 1), 1,	"Matches invalid reference");

is($obn1->fatal(1), 1,			"reset fatal");


# -------- Matches hash --------
my %data = ( 'aa' => 1, 'bb' => 'xxx', 'cc' => undef, 'dd' => "" );

is($obn1->Matches("hasho", 1, 'aa', \%data), 1,		"Matches hash integer");
is($obn1->Matches("hasho", 'xxx', 'bb', \%data), 1,	"Matches hash string");
#is($obn1->Matches("hasho", undef, 'cc', \%data), 1,	"Matches hash syntax");
is($obn1->Matches("hasho", "", 'dd', \%data), 1,	"Matches hash blank");
is($obn1->Matches("hasho", 'xxx', 'ee', \%data), 0,	"Matches hash nokey");


# -------- Matches array --------
my @data = ( 1, 'xxx', undef, "" );

is($obn1->Matches("arby", 1, 0, \@data), 1,	"Matches array integer");
is($obn1->Matches("arby", 'xxx', 1, \@data), 1,	"Matches array string");
#is($obn1->Matches("arby", undef, 2, \@data), 1,	"Matches array syntax");
is($obn1->Matches("arby", "", 3, \@data), 1,	"Matches array blank");
is($obn1->Matches("arby", 'xxx', 4, \@data), 0,	"Matches array noelement");


# -------- is_null scalars --------
is($obn1->is_null($obn1->null), 1,	"is_null definitive");
is($obn1->is_null(""), 0,		"is_null blank");
#is($obn1->is_null(undef), 0,		"is_null undef");
is($obn1->is_null("xxx"), 0,		"is_null string");

is($obn1->null("xxx"), "xxx",		"null override");
is($obn1->is_null("xxx"), 1,		"is_null override");


# -------- is_null structures --------
is($obn1->is_null("aa", \%data), 0,		"is_null hash no");
is($obn1->is_null("bb", \%data), 1,		"is_null hash yes");
is($obn1->is_null("cc", \%data), 0,		"is_null hash undef warn");
is($obn1->is_null("dd", \%data), 0,		"is_null hash blank");
is($obn1->is_null("ee", \%data), 0,		"is_null hash dne");

is($obn1->is_null(0, \@data), 0,		"is_null array no");
is($obn1->is_null(1, \@data), 1,		"is_null array yes");
is($obn1->is_null(2, \@data), 0,		"is_null array undef warn");
is($obn1->is_null(3, \@data), 0,		"is_null array blank");
is($obn1->is_null(4, \@data), 0,		"is_null array dne");


# -------- negation: is_notnull and isnt_null --------
is($obn1->is_notnull($obn1->null), 0,	"is_notnull definitive");
is($obn1->is_notnull(""), 1,		"is_notnull blank");
is($obn1->is_notnull("abc"), 1,		"is_notnull string");

is($obn1->is_notnull("aa", \%data), 1,		"is_notnull hash no");
is($obn1->is_notnull("bb", \%data), 0,		"is_notnull hash yes");
is($obn1->is_notnull(0, \@data), 1,		"is_notnull array no");
is($obn1->is_notnull(1, \@data), 0,		"is_notnull array yes");

is($obn1->isnt_null($obn1->null), 0,	"isnt_null definitive");
is($obn1->isnt_null(""), 1,		"isnt_null blank");
is($obn1->isnt_null("abc"), 1,		"isnt_null string");

is($obn1->isnt_null("aa", \%data), 1,		"isnt_null hash no");
is($obn1->isnt_null("bb", \%data), 0,		"isnt_null hash yes");
is($obn1->isnt_null(0, \@data), 1,		"isnt_null array no");
is($obn1->isnt_null(1, \@data), 0,		"isnt_null array yes");


# -------- is_blank scalars --------
is($obn1->is_blank(""), 1,		"is_blank empty");
is($obn1->is_blank(" "), 1,		"is_blank space");
is($obn1->is_blank("x"), 0,		"is_blank notempty");
#is($obn1->is_blank(undef), 0,		"is_blank syntax");


# -------- is_blank structures --------
is($obn1->is_blank("aa", \%data), 0,		"is_blank hash no");
is($obn1->is_blank("bb", \%data), 0,		"is_blank hash yes");
is($obn1->is_blank("cc", \%data), 0,		"is_blank hash undef warn");
is($obn1->is_blank("dd", \%data), 1,		"is_blank hash blank");
is($obn1->is_blank("ee", \%data), 0,		"is_blank hash dne");

is($obn1->is_blank(0, \@data), 0,		"is_blank array no");
is($obn1->is_blank(1, \@data), 0,		"is_blank array yes");
is($obn1->is_blank(2, \@data), 0,		"is_blank array undef warn");
is($obn1->is_blank(3, \@data), 1,		"is_blank array blank");
is($obn1->is_blank(4, \@data), 0,		"is_blank array dne");


# -------- negation: is_notblank and isnt_blank --------
is($obn1->is_notblank(""), 0,		"is_notblank empty");
is($obn1->is_notblank(" "), 0,		"is_notblank space");
is($obn1->is_notblank("x"), 1,		"is_notblank notempty");

is($obn1->is_notblank("aa", \%data), 1,		"is_notblank hash no");
is($obn1->is_notblank("dd", \%data), 0,		"is_notblank hash blank");
is($obn1->is_notblank(0, \@data), 1,		"is_notblank array no");
is($obn1->is_notblank(3, \@data), 0,		"is_notblank array blank");

is($obn1->isnt_blank(""), 0,		"isnt_blank empty");
is($obn1->isnt_blank(" "), 0,		"isnt_blank space");
is($obn1->isnt_blank("x"), 1,		"isnt_blank notempty");

is($obn1->isnt_blank("aa", \%data), 1,		"isnt_blank hash no");
is($obn1->isnt_blank("dd", \%data), 0,		"isnt_blank hash blank");
is($obn1->isnt_blank(0, \@data), 1,		"isnt_blank array no");
is($obn1->isnt_blank(3, \@data), 0,		"isnt_blank array blank");


__END__

=head1 DESCRIPTION

01_primitive.t - test harness for the Batch::Exec::Null class: primitives

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


#!/usr/bin/perl
#
# 01_primitive.t - test harness for the Batch::Exec::Null class: primitives
#
use strict;

use Data::Dumper;
use Logfer qw/ :all /;
#use Log::Log4perl qw/ :easy /;
use Test::More tests => 17;

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
my %data = ( 'aa' => 1, 'bb' => 'xxx', 'cc' => undef );

is($obn1->Matches("hasho", 1, 'aa', \%data), 1,		"Matches hash integer");
is($obn1->Matches("hasho", 'xxx', 'bb', \%data), 1,	"Matches hash string");
#is($obn1->Matches("hasho", undef, 'cc', \%data), 1,	"Matches hash syntax");
is($obn1->Matches("hasho", 'xxx', 'dd', \%data), 0,	"Matches hash nokey");


# -------- Matches array --------
my @data = ( 1, 'xxx', undef );

is($obn1->Matches("arby", 1, 0, \@data), 1,	"Matches array integer");
is($obn1->Matches("arby", 'xxx', 1, \@data), 1,	"Matches array string");
#is($obn1->Matches("arby", undef, 1, \@data), 1,	"Matches array syntax");
is($obn1->Matches("arby", 'xxx', 3, \@data), 0,	"Matches array noelement");

__END__

=head1 DESCRIPTION

01_primitive.t - test harness for the Batch::Exec::Null class: primitives

=head1 VERSION

___EUMM_VERSION___

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


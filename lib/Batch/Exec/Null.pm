package Batch::Exec::Null;

=head1 NAME

Batch::Exec::Null - null data element handling for the Batch Executive Framework.

=head1 AUTHOR

Copyright (C) 2022  B<Tom McMeekin> tmcmeeki@cpan.org

=head1 SYNOPSIS

  use Batch::Exec::Null;


=head1 DESCRIPTION

Null and empty value processing, providing functions to check for empty,
blank or null values.
Provides also for forcing a consistent and explicit value where ambiguity
exists.

  verbs:
  - non-fatal: is, isnt / is_not (which are aliases)
  - fatal: check

  adjectives:
  - blank (whitespace)
  - null (explicit)
  - empty (blank, missing or undefined)

=head2 ATTRIBUTES

=over 4

=item OBJ->arguments

The error message reported when an operator has insufficient arguments.

=item OBJ->blank

Get ot set the REGEXP used to test a blank string.  A default applies.

=item OBJ->match

The matched value from the last comparison operation.

=item OBJ->error

The error message reported when method syntax is not complied with.

=item OBJ->novalue

The error message reported when an argument is undefined.

=item OBJ->operator

The error message reported when an invalid operator is specified.

=item OBJ->syntax

The error message reported when any functions are called incorrectly.

=back

=cut

use strict;

use parent 'Batch::Exec';

# --- includes ---
use Carp qw(cluck confess);
use Data::Dumper;


# --- package constants ---
use constant RE_BLANK => qr/^\s*$/;

use constant S_NULL => "(null)";


# --- package globals ---
our $AUTOLOAD;
#our @EXPORT = qw();
#our @ISA = qw(Exporter);
our @ISA;
our $VERSION = sprintf "%d.%03d", q[_IDE_REVISION_] =~ /(\d+)/g;


# --- package locals ---
my $_n_objects = 0;
my $_s_null = S_NULL;

my %_attribute = (	# _attributes are restricted; no direct get/set
	_global => 1,		# boolean: class global null value
	_null_g => \$_s_null,
	_null_l => S_NULL,
	arguments => "method %s() operator [%s] requires %s arguments",
	blank => RE_BLANK,
	error => "method %s() must pass a hash or array reference",
	match => undef,
	novalue => "method %s() argument %s is undefined",
	operator => "method %s() invalid operator [%s]; must be one of: { %s }",
	syntax => "SYNTAX: %s(EXPR, [REF])",
);

#sub INIT { };

sub AUTOLOAD {
	my $self = shift;
	my $type = ref($self) or confess "$self is not an object";

	my $attr = $AUTOLOAD;
	$attr =~ s/.*://;   # strip fully−qualified portion

	confess "FATAL older attribute model"
		if (exists $self->{'_permitted'} || !exists $self->{'_have'});

	confess "FATAL no attribute [$attr] in class [$type]"
		unless (exists $self->{'_have'}->{$attr} && $self->{'_have'}->{$attr});
	if (@_) {
		return $self->{$attr} = shift;
	} else {
		return $self->{$attr};
	}
}


sub DESTROY {
	local($., $@, $!, $^E, $?);
	my $self = shift;

	#printf "DEBUG destroy object id [%s]\n", $self->{'_id'});

	-- ${ $self->{_n_objects} };
}


sub new {
	my ($class) = shift;
	my %args = @_;	# parameters passed via a hash structure

	my $self = $class->SUPER::new;	# for sub-class
	my %attr = ('_have' => { map{$_ => ($_ =~ /^_/) ? 0 : 1 } keys(%_attribute) }, %_attribute);

	bless ($self, $class);

	map { push @{$self->{'_inherent'}}, $_ if ($attr{"_have"}->{$_}) } keys %{ $attr{"_have"} };

	while (my ($attr, $dfl) = each %attr) { 

		unless (exists $self->{$attr} || $attr eq '_have') {
			$self->{$attr} = $dfl;
			$self->{'_have'}->{$attr} = $attr{'_have'}->{$attr};
		}
	}

	while (my ($method, $value) = each %args) {

		confess "SYNTAX new(, ...) value not specified"
			unless (defined $value);

		$self->log->debug("method [self->$method($value)]");

		$self->$method($value);
	}
	# ___ additional class initialisation here ___
#	$self->log->debug(sprintf "self [%s]", Dumper($self));

	return $self;
}

=head2 METHODS

=over 4

=item OBJ->Compare(METHOD, OPERATOR, ...)

INTERNAL ROUTINE ONLY.
Execute the comparison stipulated by OPERATOR (one of: 'eq', 'like'), to
one or both of the values passed in EXPR (an operator may be unary in nature).
Returns a boolean, whereby a successful match is TRUE, and FALSE otherwise.

=cut

sub Compare {
	my $self = shift;
	my $method = shift;
	my $op = shift;

	confess "SYNTAX: Compare(METHOD, OPERATOR, ...)" unless (
		defined($method) && defined($op));

	$self->log->trace("method [$method] op [$op]");

	# check operator

	my %op = ('eq' => 2, 'like' => 2, 'noop' => 0);
	my $help = join(', ', sort keys %op);
	my $msg = sprintf($self->operator, $method, $op, $help);

	$self->log->logconfess($msg) unless exists($op{$op});

	# check arguments

	my $argw = $op{$op};
	my $args = scalar(@_);
	$self->log->trace(sprintf "argw [$argw] args [$args]");

	$msg = sprintf($self->arguments, $method, $op, $argw);

	$self->log->logconfess($msg) unless ($args == $argw);

	my @values; for (my $ss = 0; $ss < $args; $ss++) {

		if (defined $_[$ss]) {

			push @values, $_[$ss];
		} else {
			$self->log->warn(sprintf $self->novalue, $method, $ss);

			return 0;
		}
	}
	$self->log->trace(sprintf "values [%s]", Dumper(\@values));

	# perform the comparison

	my $rv = 0; if ($op eq 'eq') {

		$rv = 1 if ($values[0] eq $values[1]);

	} elsif ($op eq 'like') {

		$rv = 1 if ($values[0] =~ $values[1]);

	} elsif ($op eq 'noop') {

		$rv = 1;
	} else {
		$self->log->logconfess($msg);
	}
	$self->log->trace("rv [$rv]");

	return $rv;
}

=item OBJ->Matches(METHOD, VALUE, ELEMENT, [REF])

INTERNAL ROUTINE ONLY.
Validate that VALUE matches ELEMENT (or indeed the hash/array referenced by REF,
in which case the ELEMENT takes the place of the associated key/subscript).
The METHOD passed is to provide syntax error reorting
(refer to the B<syntax> attribute).
Returns a boolean, whereby a successful match is TRUE, and FALSE otherwise.

=cut

sub Matches {
	my $self = shift;
	my $meth = shift;
	my $v2 = shift;
	my $v1 = shift;
	my $ref = shift;

	$self->log->logconfess(sprintf $self->syntax, $meth) unless (
		defined($meth) && defined($v2) &&
		defined($v1) && ref($v1) eq '');

	$self->match(undef);	# will use this to store the match

	$self->log->trace("v2 [$v2] v1 [$v1]");

	my $op = (ref($v2) eq 'Regexp') ? 'like' : 'eq';

	if (defined($ref)) {

		if (ref($ref) eq 'HASH') {

			if (exists($ref->{$v1})) {

				my $w = $self->match($ref->{$v1});

				return 1
					if ($self->Compare($meth, $op, $w, $v2));
			}
		} elsif (ref($ref) eq 'ARRAY') {

			if (exists($ref->[$v1])) {

				my $w = $self->match($ref->[$v1]);

				return 1
					if ($self->Compare($meth, $op, $w, $v2));
			}
		} else {
			$self->cough(sprintf $self->error, $meth);
		}
	} else {
		return 1
			if ($self->Compare($meth, $op, $self->match($v1), $v2));
	}
	return 0;
}

=item OBJ->global(BOOLEAN)

Get or set a boolean value which controls whether the B<null> value will take a
object-specific (local) or class-global value.
The latter is useful for when this class is utilised in disparate classes.
The default value is true, i.e. a global value is assumed.

=cut

sub global {
	my $self = shift;

	if (@_) {
		my $bool = shift;

		$self->log->trace("bool [$bool]");

		confess "SYNTAX: global(BOOLEAN)" unless defined($bool);

		$self->{'_global'} = ($bool) ? 1 : 0;
	}
	$self->log->trace(sprintf "_global [%d]", $self->{'_global'});

	return $self->{'_global'};
}

=item OBJ->is_blank(EXPR, [REF])

Check if the string passed in EXPR is a blank or whitespace string.
If REF is also supplied, which may be an array or hash, then EXPR is treated as
a hash key or array subscript.
Returns a boolean.

=cut

sub is_blank {
	my $self = shift;
	my $elem = shift;
	my $ref = shift;

	return $self->Matches("is_blank", $self->blank, $elem, $ref);
}

=item OBJ->is_notblank(EXPR, [REF])

The complementary method to B<is_blank>.

=cut

sub is_notblank {
	my $self = shift;

	return 0 if ($self->is_blank(@_));

	return 1;
}

=item OBJ->is_empty(EXPR, [REF])

Check if the string passed in EXPR is either null or blank (or non-existent).
If REF is also supplied, which may be an array or hash, then EXPR is treated as
a hash key or array subscript.
Returns a boolean.

=cut

sub is_empty {
	my $self = shift;
	my $elem = shift;
	my $ref = shift;

	return 1
		if $self->is_blank($elem, $ref);

	return 1
		unless defined($self->match);

	return 1
		if $self->is_null($elem, $ref);

	return 0;
}

=item OBJ->is_notempty(EXPR, [REF])

The complementary method to B<is_empty>.

=cut

sub is_notempty {
	my $self = shift;

	return 0 if ($self->is_empty(@_));

	return 1;
}

=item OBJ->is_null(EXPR, [REF])

Check if the string passed in EXPR is the defined null value.
If REF is also supplied, which may be an array or hash, then EXPR is treated as
a hash key or array subscript.
Returns a boolean.

=cut

sub is_null {
	my $self = shift;
	my $elem = shift;
	my $ref = shift;

	return $self->Matches("is_null", $self->null, $elem, $ref);
}

=item OBJ->is_notnull(EXPR, [REF])

The complementary method to B<is_notnull>.

=cut

sub is_notnull {
	my $self = shift;

	return 0 if ($self->is_null(@_));

	return 1;
}

=item OBJ->null([EXPR])

Get or set the null value.  A default applies.
Refer also to the B<global> method.

=cut

sub null {
	my $self = shift;

	if (@_) {
		my $expr = shift;

		$self->log->trace("expr [$expr]");

		if ($self->{'_global'}) {

			${ $self->{'_null_g'} } = $expr;
		} else {

			$self->{'_null_l'} = $expr;
		}
	}
	return ${ $self->{'_null_g'} }
		if ($self->{'_global'});

	return $self->{'_null_l'};
}

=item OBJ->nvl(EXPR, [REF])

Guarantee a non-null value for the EXPR passed, even if undefined.
Whitespace (blanks) will be replaced with the B<null> attribute.

=cut

sub nvl {
	my $self = shift;
	my $elem = shift;
	my $ref = shift;

	return $self->null	# should produce a non-fatal result
		unless defined($elem);

	confess "SYNTAX: nvl(EXPR, [REF])" unless (ref($elem) eq '');

	return $self->null
		if ($self->Matches("nvl", $self->null, $elem, $ref));

	return $self->null
		if $self->is_blank($elem, $ref);

	return $self->null
		unless defined($self->match);

	$self->log->trace(sprintf "elem [$elem] match [%s]", $self->match);

	return $self->match;
}

=back

=head2 ALIASED METHODS

The following method aliases have also been defined:

	alias		base method
	------------	------------	
	isnt_blank	is_notblank
	isnt_empty	is_notempty
	isnt_null	is_notnull

=cut

*isnt_blank = \&is_notblank;
*isnt_empty = \&is_notempty;
*isnt_null = \&is_notnull;

#sub END { }

1;

__END__


=head1 VERSION

_IDE_REVISION_

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published
by the Free Software Foundation; either version 3 of the License,
or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 SEE ALSO

L<perl>.

=cut


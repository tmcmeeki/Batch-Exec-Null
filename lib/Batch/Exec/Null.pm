package Batch::Exec::Null;

=head1 NAME

Batch::Exec::Null: null data element handling for the Batch Executive Framework.

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
  - is (non-fatal)
  - check (fatal)

  adjectives:
  - blank (whitespace)
  - null (explicit)
  - empty (blank, missing or undefined)

=head2 ATTRIBUTES

=over 4

=item OBJ->null

The string which represents a null (or blank) value.

=back

=cut

use strict;

use parent 'Batch::Exec';

# --- includes ---
use Carp qw(cluck confess);
use Data::Dumper;


# --- package constants ---
use constant S_NULL => "(null)";


# --- package globals ---
our $AUTOLOAD;
#our @EXPORT = qw();
#our @ISA = qw(Exporter);
our @ISA;
our $VERSION = '0.001';


# --- package locals ---
my $_n_objects = 0;
my $_s_null = S_NULL;

my %_attribute = (	# _attributes are restricted; no direct get/set
	_global => 0,		# boolean: class global null value
	_null_g => \$_s_null,
	_null_l => S_NULL,
	error => "must pass a hash or array",
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

=item OBJ->global(BOOLEAN)

Get or set a boolean value which controls whether the B<null> value will take a
object-specific (local) or class-global value.
The latter is useful for when this class is utilised in disparate classes.
The default value is false, i.e. local.

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

=item OBJ->is_blank(EXPR)

Check if the string passed in EXPR is a blank or whitespace string.

=cut

sub is_blank {
	my $self = shift;
	my $str = shift;
	confess "SYNTAX: is_blank(EXPR)" unless defined ($str);

#	return -1 unless defined($str);
#Will return a negative value if EXPR is undefined.

	return 1 if ($str =~ /^\s*$/);

	return 0;
}

=item OBJ->is_notempty(EXPR, [HASHREF])

The complementary method to B<is_empty> will report a BOOLEAN denoting if
the EXPR element of the HASH has a valid (not-empty) value.

=cut

sub is_notempty {
	my $self = shift;
	my $key = shift;
	my $rh = shift;

	confess "SYNTAX: is_notempty(EXPR, [HASHREF])" unless (
		defined($key) && ref($key) eq '');

	if (defined($rh)) {
		if (ref($rh) eq 'HASH') {
		} elsif (ref($rh) eq 'ARRAY') {
		} else {
			$self->cough($self->error);
		}
	}

	# MUST DEFINE NON-FATAL PROCESSING FROM PARENT CLASS? i.e. $self->cough(MESG)

	return 0 unless defined($key);

	return 0 unless (exists $rh->{$key});

#	NOT REALLY HAPPY WITH THE NEXT EXPRESSION. should be in a separate function, e.g. is_empty

	return 0 if ($self->is_blank( $rh->{$key} ));

	return 0 if ($rh->{$key} eq $self->null);

	return 1;
}

=item OBJ->is_empty(EXPR, [HASHREF])

The complementary method to B<is_notempty> will report a BOOLEAN denoting if
the EXPR element of the HASH has a null value (tolerant to a non-existent
element).

=cut

sub is_empty {
	my $self = shift;
	my $key = shift;
	my $rh = shift;
	confess "SYNTAX: is_empty(EXPR, [HASHREF])" unless (
		defined($rh) && ref($rh) eq 'HASH'
	);

	return 1 unless defined($key);

	if (exists $rh->{$key}) {

		return 1 if ($self->is_blank( $rh->{$key} ));

		return 1 if ($rh->{$key} eq $self->null);

		return 0;
	}
	return 1;
}

=item OBJ->is_null(EXPR, [REF])

The complementary method to B<is_notnull> will report a BOOLEAN denoting if
the EXPR element of the HASH has a null value (tolerant to a non-existent
element).

=cut

sub is_null {
	my $self = shift;
	my $elem = shift;
	my $ref = shift;
	confess "SYNTAX: is_null(EXPR, [REF])" unless defined($elem);

	if (defined($ref)) {
		if (ref($ref) eq 'HASH') {

			return 1 if (exists($ref->{$elem})
				&& $ref->{$elem} eq $self->null);

		} elsif (ref($ref) eq 'ARRAY') {

			return 1 if (exists($ref->[$elem])
				&& $ref->[$elem] eq $self->null);
		} else {
			$self->cough($self->error);
		}
	}
	return 1 if ($ref eq $self->null);

	return 0;
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

=item OBJ->nvl(EXPR)

Guarantee a non-null value for the EXPR passed, even if undefined.
Whitespace (blanks) will be replaced with the B<null> attribute.

=cut

sub nvl {
	my $self = shift;
	my $value = shift;

	return $self->null
		unless defined($value);

	return $self->null
		if $self->is_blank($value);

	$self->log->trace("value [$value]");

	return $value;
}

#sub END { }

1;

__END__

=back

=head1 VERSION

___EUMM_VERSION___

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


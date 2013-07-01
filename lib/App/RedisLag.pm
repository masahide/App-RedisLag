package App::RedisLag;
use strict;
use warnings;
our $VERSION = '0.01';

use Time::HiRes;
use App::RedisLag::Redis;

sub new{
	my $class = shift;

	my $self = bless {
		key			=> "ae9974b9-0ff5-4f7c-a572-4442fa0ef2d5-". $$,
		lag			=> 0,
		timeout		=> 120,
		wait		=> 0.020,
		set_time	=> undef,
		master		=> undef,
		slave		=> undef,
		slave_host	=> 'localhost',
		slave_port	=> 6379,
		master_host	=> 'localhost',
		master_port	=> 6379,
		ring_buf	=> [],
		@_,
	}, $class;
	$self->{slave}  = App::RedisLag::Redis->new(host=>$self->{slave_host},port=>$self->{slave_port});
	$self->{master} = App::RedisLag::Redis->new(host=>$self->{master_host},port=>$self->{master_port});
	$self;
}

#アクセサ
sub key {
	my $self = shift ;
	return ( $_[0] )?  $self->{key} = $_[0] : $self->{key};
}
sub lag {
	my $self = shift ;
	return ( $_[0] )?  $self->{lag} = $_[0] : $self->{lag};
}
sub timeout {
	my $self = shift ;
	return ( $_[0] )?  $self->{timeout} = $_[0] : $self->{timeout};
}
sub wait {
	my $self = shift ;
	return ( $_[0] )?  $self->{wait} = $_[0] : $self->{wait};
}
sub set_time {
	my $self = shift ;
	return ( $_[0] )?  $self->{set_time} = $_[0] : $self->{set_time};
}
sub add_ring_buf {
	my ($self,$value) = @_;
	push(@{$self->{ring_buf}},$value);
	if($#{$self->{ring_buf}} >= 600){
		shift(@{$self->{ring_buf}});
	}
}

sub sum {
	my ($self) = @_;
	my $time = Time::HiRes::time - 330;
	my $counter = 0;
	my $sum = 0;
	my $max = 0;
	my $min = $self->{timeout};
	foreach my $data (@{$self->{ring_buf}}){
		if($data->{date} > $time){
			$sum += $data->{time};
			$max = $data->{time} if($max<$data->{time});
			$min = $data->{time} if($min>$data->{time});
			$counter++;
		}
	}
	my $avg = $sum / $counter;
	return {avg=>$avg,max=>,$max,min=>$min,count=>$counter};
}


sub run_loop {
	my ($self) = @_;
	while(1){
		my $time = $self->set_check_value();
		if($time){
			$time  = $self->get_check_value($time);
		}
		if($time){
			$self->add_ring_buf({date=>time(),time=>$time});
		}
		sleep(1);
	}
}

sub set_check_value {
	my ($self) = @_;
	$self->{set_time} = Time::HiRes::time;
	if($self->{master}->set_value($self->{key},$self->{set_time})){
		return $self->{set_time};
	}
	return 0;
}
sub get_check_value {
	my ($self, $set_time) = @_;
	if($set_time){ $self->{set_time} = $set_time; }
	$set_time = $self->{set_time};
	if(!$set_time){
		return 0;
	}
	while(1){
		my $time = Time::HiRes::time;
		if($self->{timeout} < ($time - $set_time)){
			return $self->{timeout};
		}
		my $value = $self->{slave}->get_value($self->{key});
		if(!$value){
			return $value;
		}
		elsif($set_time eq $value){
			return $time - $set_time;
		}
		Time::HiRes::sleep($self->{wait});
	}
}

1;
__END__

=head1 NAME

App::RedisLag -

=head1 SYNOPSIS

  use App::RedisLag;

=head1 DESCRIPTION

App::RedisLag is

=head1 AUTHOR

YAMASAKI Masahide E<lt>masahide.y@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

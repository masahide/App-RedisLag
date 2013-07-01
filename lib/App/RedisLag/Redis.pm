package App::RedisLag::Redis;

use IO::Socket::INET;
use Time::HiRes;


sub new{
	my $class = shift;

	my $self = bless {
		key			=> "ae9974b9-0ff5-4f7c-a572-4442fa0ef2d5",
		lag			=> 0,
		timeout		=> 120.000,
		wait		=> 0.020,
		set_time	=> undef,
		socket		=> undef,
		host		=> "localhost",
		port		=> 6379,
		pass		=> undef,
		server		=> undef,
		error_msg	=> "",
		@_,
	}, $class;
	$self;
}


#アクセサ
sub lag{
	$self = shift ;
	return ( $_[0] )?  $self->{lag} = $_[0] : $self->{lag};
}
sub set_time{
	$self = shift ;
	return ( $_[0] )? $self->{set_time} = $_[0] :  $self->{set_time};
}
sub timeout{
	$self = shift ;
	return ( $_[0] )? $self->{timeout} = $_[0] :  $self->{timeout};
}
sub error_msg{
	$self = shift ;
	return ( $_[0] )?  $self->{error_msg} = $_[0] : $self->{error_msg};
}

sub set_check_value {
	my ($self) = @_;
	$self->{set_time} = Time::HiRes::time;
	if($self->set_value($self->{key},$self->{set_time})){
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
		$time = Time::HiRes::time;
		if($self->{timeout} < ($time - $set_time)){
			return $self->{timeout};
		}
		$value = $self->get_value($self->{key});
		if(!$value){
			return $value;
		}
		elsif($set_time eq $value){
			return $time - $set_time;
		}
		Time::HiRes::sleep($self->{wait});
	}
}

sub error {
	my ($self, $msg, $err_no) = @_;
	$self->{error_msg} = "$msg : $err_no";
	return 0;
}

sub connect {
	my ($self, $host, $port, $pass) = @_;
	if($self->{socket}){
		if($self->{socket}->connected){
			return $self; # 接続済み
		}
	}
	if($host){ $self->{host} = $host; }
	if($port){ $self->{port} = $port; }
	my $server = $self->{host}.":".$self->{port};
	$self->{server}=$server;
	my $sock = IO::Socket::INET->new(
		PeerAddr=>$server,
		Proto=>'tcp');
	if($sock){
		if ($pass) {
			$sock->print("AUTH $pass \r\n");
			<$sock> || return $self->error("[$server] socket auth error",$!);
		}
	}
	else{
		return $self->error("socket connect error: $!");
	}
	$self->{socket} = $sock;

	return $self;
}

sub close {
	my ($self) = @_;
	$s = $self->{socket};
	return $s ? $s->close() : $s;
}

sub DESTROY {
	my ($self) = @_;
	$self->close();
}

sub set_value {
	my ($self,$key,$value) = @_;
	$s = $self->{socket};
	$server = $self->{server};
	if(!$s->connected){
		return $self->error("[$server] Disconnected.",-1);
	}
	$s->print("SET $key $value\r\n");
	my $status = <$s> || return $self->error("[$server] socket read error", $!);
	if($status !~ /^\+OK/){
		return $self->error("[$server] set_value socket read error[$status]",-1);
	}
	return $self;
}

sub get_value {
	my ($self,$key) = @_;
	$s = $self->{socket};
	$server = $self->{server};
	if(!$s->connected){
		return $self->error("[$server] Disconnected.",-1);
	}
	$s->print("GET $key\r\n");
	my $count = <$s> || return "[$server] get_value1 socket read1 error: $!";
	$s->read(my $buf, substr($count, 1) ) or return $self->error("[$server] get($key) socket read2 error", $!.":".$count);
	$s->getline() or return $self->error("[$server] get($key) socket read3 error", $!.":".$count);
	return $buf;
}


	
	


1;
__END__

=head1 NAME





=cut

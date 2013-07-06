package App::RedisLag::Redis;
use strict;
use warnings;

use IO::Socket::INET;
use IO::Select;

use constant EXPIRE => 600;

sub new{
    my $class = shift;

    my $self = bless {
        socket      => undef,
        host        => "localhost",
        port        => 6379,
        pass        => undef,
        server      => undef,
        error_msg   => "",
        @_,
    }, $class;
    $self;
}


#アクセサ
sub error_msg{
    my $self = shift ;
    return ( $_[0] )?  $self->{error_msg} = $_[0] : $self->{error_msg};
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
    if($pass){ $self->{port} = $pass; }
    my $server = $self->{host}.":".$self->{port};
    $self->{server}=$server;
    my $sock = IO::Socket::INET->new(
        PeerAddr=>$server,
        TimeOut=>5,
        Blocking=>0,
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
    my $s = $self->{socket};
    if($s){
        if($s->connected){
            return $s->close();
        }
    }
    return $s;
}

sub DESTROY {
    my ($self) = @_;
    $self->close();
}

sub set_value {
    my ($self,$key,$value) = @_;
    my $status;
    my @lines = $self->write_read("SET $key $value\r\nEXPIRE $key ".EXPIRE."\r\n");
    if(!$#lines){ return 0;}
    if($#lines != 1 ||
       ($lines[0] !~ /^\+OK/ && $lines[1] !~ /^\:1/)
    ){
        return $self->error("[".$self->{server}."] get($key) socket read error", join(",",@lines));
    }
    return $self;
}

sub get_value {
    my ($self,$key) = @_;
    $self->connect();
    my @lines = $self->write_read("GET $key\r\n");
    if(!$#lines){ return 0;}
    if($#lines != 1){
        return $self->error("[".$self->{server}."] get($key) socket read error", -1);
    }
    return $lines[1];
}


sub write_read {
    my ($self,$in) = @_;
    $self->connect();
    my $s = $self->{socket};
    my $server = $self->{server};
    my $selecter = IO::Select->new;
    $selecter->add($s);
    $s->print($in);
    $s->flush();
    my $buf;
    my @lines;
    my @ready = $selecter->can_read(5);
    if(@ready){
        my $len = read($s, $buf, 4096);
        $selecter->remove($s);
        @lines = split(/\r\n/,$buf);
    }
    else{
        @lines = ();
    }
    $selecter->remove($s);
    return @lines;
}
    
    


1;
__END__

=head1 NAME





=cut

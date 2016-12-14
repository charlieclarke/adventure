#!/usr/bin/perl
#
use LWP::Simple;
use HTTP::Cookies;
use Time::HiRes qw(time);
use Data::Dumper;


$registerurl = "http://ec2-176-34-195-123.eu-west-1.compute.amazonaws.com/adventureweb/adventureweb/SIMClient.php?secret=12345abcdefg&REGISTERNUMBER=yes&Reg=Register";
$sowurl = "http://ec2-176-34-195-123.eu-west-1.compute.amazonaws.com/adventureweb/adventureweb//timeline-svcSIM.php?action=SOW";
$sendSIMurl = "http://ec2-176-34-195-123.eu-west-1.compute.amazonaws.com/adventureweb/adventureweb//timeline-inboundSIM.php?To=SIM_1&Body=TESTMESSAGE";

my $browser = LWP::UserAgent->new;

my $cookie_jar = HTTP::Cookies->new( );
$browser->cookie_jar( $cookie_jar );
my $start = time;
$name=$ARGV[0];
print "name is $name\n";
my $response = $browser->get( $registerurl . "&Description=" . $name );

die "Can't get $url -- ", $response->status_line
   unless $response->is_success;


print $cookie_jar->as_string();
$jar = $cookie_jar->as_string();

$jar =~ /SIMCOOKIE=(.*?);/;
$guid = $1;
print "guid: $guid\n";

$num = 10;
$sendSIMurl = $sendSIMurl . "&GUID=$guid&From=$name";
print "using send url $sendSIMurl\n";
for(my $i = 0; $i < $num; $i++) {
my $response = $browser->get($sowurl);
my $response = $browser->get($sendSIMurl);

}

my $stop = time;

#print $response->content;
$diff = $stop - $start;
print "\n\n$name: time: $start $stop $diff\n";
#
#

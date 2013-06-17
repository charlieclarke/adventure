#!/opt/local/bin/perl
#
#
#this script adds in support for the kill thread action...
# which will kill items off the timeline of its child type, for the inboud number.
# this is basically to support default behaviours - if you make a default behaviour, and the player
# does the irght thing in the meantime, you can kill the default thread.
#
use DBI;
use Config::Simple;
my $hostname = `/bin/hostname`;
print "got hostname of $hostname\n";
if ($hostname =~ /local/) {
        $configlocation = "/var/tmp/config.local";
} else {
        $configlocation = "/var/cache/timeline/config.local";
}
#sort out configs
use Config::Simple;

my $cfg = new Config::Simple($configlocation);


my $db_location = $cfg->param('database.databasepath');

my $ACTIONTYPE_OUTBOUNDMP3_RESPAWN = 1;

my $db = DBI->connect("dbi:SQLite:$db_location", "", "",
{RaiseError => 1, AutoCommit => 1});


$db->do("INSERT INTO Action VALUES (12,'Kill-off children', 'number is irrelevent to this thread ','','This action kills threads of its chile types which have been sent to the inbound number. Threads of this type have to be sent to a number (or group of numbers). You cannot insert it directly into the TimeLine.')");


my $all = $db->selectall_arrayref("SELECT * FROM Thread");





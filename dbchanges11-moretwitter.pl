#!/opt/local/bin/perl
#
#
# this dbchanges adds support for twitter.
#
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


$db->do("alter table TNumber add column TwitterConsumerKey TEXT default ''");
$db->do("alter table TNumber add column TwitterConsumerKeySecret TEXT default ''");





my $all = $db->selectall_arrayref("SELECT * FROM Thread");





#!/opt/local/bin/perl
#
#
# this db script adds in the table needed for the IMS system - the SMS replacement
# that can send messages 
#
# it also sets up the concept of CODENAMES
# and adds the concept of SIM number map which connects details for SIM [guid etc] to numbers
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


$db->do("DROP TABLE IF EXISTS SIMNumberMap ");
$db->do("DROP TABLE IF EXISTS SIMMessage ");
$db->do("CREATE TABLE SIMNumberMap (SNMID INTEGER PRIMARY KEY, NumberID INTEGER, GUID TEXT)");
$db->do("CREATE TABLE SIMMessage (SIMID INTEGER PRIMARY KEY, DstNumberID INTEGER,SIMTime DATETIME, SIMText TEXT, SIMIsRcvd INTEGER, SIMIsOutbound INTEGER )");




my $all = $db->selectall_arrayref("SELECT * FROM Thread");





#!/opt/local/bin/perl
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

$db->do("INSERT INTO Action VALUES (10,'DialTone response', 'Number is irrelevant for this thread ',' ','This action describes how to respond to dial tones/ key presses. ')");

$db->do("INSERT INTO Thread VALUES (3, '1 off call Charlies Phone', 2,'1','hello.mp3',0,0,23,59,0,0)");
$db->do("INSERT INTO Thread VALUES (1, 'default inbound call behaviour', 5,'1','hello [InboundName]',0,0,23,59,0,0)");
$db->do("INSERT INTO Thread VALUES (2, 'default inbound SMS behaviour', 8,'1','',0,0,23,59,0,0)");
my $all = $db->selectall_arrayref("SELECT * FROM Thread");


$db->do("DROP TABLE IF EXISTS TimeLine");
$db->do("CREATE TABLE TimeLine (id INTEGER PRIMARY KEY, ThreadId INTEGER, ActivityTime DATETIME, Completed INTEGER, CompletedTime DATETIME, Description TEXT, Notes TEXT, AdditionalNumberID INTEGER)");


foreach my $row (@$all) {
my ($id, $first, $last) = @$row;
print "$id|$first|$lastn";
}




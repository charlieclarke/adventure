#!/opt/local/bin/perl
#
#

use DBI;
use Config::Simple;

my $cfg = new Config::Simple('config.local');
my $db_location = $cfg->param('database.databasepath');

my $ACTIONTYPE_OUTBOUNDMP3_RESPAWN = 1;

my $db = DBI->connect("dbi:SQLite:$db_location", "", "",
{RaiseError => 1, AutoCommit => 1});

$db->do("DROP TABLE IF EXISTS Thread");
$db->do("CREATE TABLE Thread (id INTEGER PRIMARY KEY, ThreadDescription TEXT, ActionType INTEGER, DestNumber TEXT, mp3Name TEXT, StartTimeHour INTEGER, StartTimeMinute INTEGER, StopTimeHour INTEGER, StopTimeMinute INTEGER, FrequencyMinutes TEXT, ChildThreadID TEXT)");

$db->do("INSERT INTO Thread VALUES (1, 'repeat call Charlies phone', 1,'+447971805821','test.mp3',0,0,23,59,20,0)");
$db->do("INSERT INTO Thread VALUES (2, '1 off call Charlies Phone', 2,'+447971805821','test.mp3',0,0,23,59,0,0)");
$db->do("INSERT INTO Thread VALUES (3, 'multi call charlies phone', 3,'+447971805821','test.mp3',6,0,18,59,'0,15,30,45',2)");
my $all = $db->selectall_arrayref("SELECT * FROM Thread");


$db->do("DROP TABLE IF EXISTS TimeLine");
$db->do("CREATE TABLE TimeLine (id INTEGER PRIMARY KEY, ThreadId INTEGER, ActivityTime DATETIME, Completed INTEGER, CompletedTime DATETIME, Description TEXT, Notes TEXT)");


foreach my $row (@$all) {
my ($id, $first, $last) = @$row;
print "$id|$first|$lastn";
}




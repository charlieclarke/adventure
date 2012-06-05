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

$db->do("DROP TABLE IF EXISTS Thread");
$db->do("DROP TABLE IF EXISTS Action");
$db->do("DROP TABLE IF EXISTS Number");
$db->do("DROP TABLE IF EXISTS Groups");
$db->do("DROP TABLE IF EXISTS GroupNumber");
$db->do("DROP TABLE IF EXISTS CallTrack");
$db->do("DROP TABLE IF EXISTS DefaultInboundThread");
$db->do("CREATE TABLE Thread (id INTEGER PRIMARY KEY, ThreadDescription TEXT, ActionType INTEGER, DestNumber INTEGER, mp3Name TEXT, StartTimeHour INTEGER, StartTimeMinute INTEGER, StopTimeHour INTEGER, StopTimeMinute INTEGER, FrequencyMinutes TEXT, ChildThreadID TEXT)");
$db->do("CREATE TABLE CallTrack (TrackID INTEGER PRIMARY KEY, IsOutbound INTEGER, ThreadID INTEGER, TrackNumberID INTEGER, TimeLineID INTEGER, TrackTime DATETIME, TwilioID TEXT, TwilioFollowup INTEGER, StatusText TEXT, InboundDetails TEXT)");
$db->do("CREATE TABLE Number (NumberID INTEGER PRIMARY KEY, NumberDescription TEXT, Number TEXT)");

$db->do("INSERT INTO Number VALUES (1,'charlie''s phone', '+447971805821')");

$db->do("CREATE TABLE Groups (GroupID INTEGER PRIMARY KEY, GroupName TEXT)");
$db->do("INSERT INTO Groups VALUES (1,'just charlie')");

$db->do("CREATE TABLE DefaultInboundThread (ThreadID INTEGER) ");
$db->do("INSERT INTO  DefaultInboundThread values (1) ");

$db->do("CREATE TABLE GroupNumber (GroupNumberID INTEGER PRIMARY KEY, GNGroupID INTEGER, GNNumberID INTEGER)");
$db->do("INSERT INTO GroupNumber VALUES (1,1,1)");

$db->do("CREATE TABLE Action (ActionTypeID INTEGER PRIMARY KEY, ActionName TEXT, MinutesBeforeText TEXT, MinutesAfterText TEXT, Description TEXT)");

$db->do("INSERT INTO Action VALUES (1,'Repeat Call', 'Call every ',' minutes','This action calls the number at a set inverval. Once the call is made, it inserts places a new call on the thread at the correct interval. If a child is set, then that child will be spawned on answer')");
$db->do("INSERT INTO Action VALUES (2,'One-off Call', 'Wait ',' minutes after a spawn','This action calls the number once. If the call is spawned as a child, the child will be spawned with an offset of &lt;frequency&rt; minutes. If a child is set, then that child will be spawned on answer')");
$db->do("INSERT INTO Action VALUES (3,'Generate Call List', 'Insert at (',') minutes past the hour','This action generate threads starting at the specified minutes past the hour. The minutes are set using the &lt;frequency&rt; field as a comma-searated list')");;
$db->do("INSERT INTO Action VALUES (4,'Send SMS', 'Wait ',' minutes after a spawn','This action sends an SMS to the specified number. The mp3name is the text of the SMS. If the SMS is spawned as a child, the child will be spawned with an offset of &lt;frequency&rt; minutes.')");
$db->do("INSERT INTO Action VALUES (5,'Inbound Call Text Reply', 'Number is irrelevant for this thread ',' ','This action describes what to do for an incoming call - it will play the text using text2speech.')");

$db->do("INSERT INTO Thread VALUES (2, '1 off call Charlies Phone', 2,'1','hello.mp3',0,0,23,59,0,0)");
$db->do("INSERT INTO Thread VALUES (1, 'default inbound behaviour', 5,'1','hello [InboundName]',0,0,23,59,0,0)");
my $all = $db->selectall_arrayref("SELECT * FROM Thread");


$db->do("DROP TABLE IF EXISTS TimeLine");
$db->do("CREATE TABLE TimeLine (id INTEGER PRIMARY KEY, ThreadId INTEGER, ActivityTime DATETIME, Completed INTEGER, CompletedTime DATETIME, Description TEXT, Notes TEXT)");


foreach my $row (@$all) {
my ($id, $first, $last) = @$row;
print "$id|$first|$lastn";
}




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


#$db->do("DROP TABLE IF EXISTS SIMNumberMap ");
#$db->do("DROP TABLE IF EXISTS SIMMessage ");
#$db->do("CREATE TABLE SIMNumberMap (SNMID INTEGER PRIMARY KEY, NumberID INTEGER, GUID TEXT)");
#$db->do("CREATE TABLE SIMMessage (SIMID INTEGER PRIMARY KEY, DstNumberID INTEGER,SIMTime DATETIME, SIMText TEXT, SIMIsSupressed INTEGER default 0, SIMIsRcvd INTEGER, SIMIsOutbound INTEGER )");



$db->do("DROP TABLE IF EXISTS Stash ");
$db->do("CREATE TABLE Stash (StashID INTEGER PRIMARY KEY, NumberID INTEGER,StashTime DATETIME, StashKey TEXT, StashValue TEXT )");


$db->do("alter table CallTrack add column RawText TEXT default ''");
$db->do("alter table Thread add column Active INTEGER default 1");


#$db->do("INSERT INTO Action VALUES (13,'Inbound SIM', 'Number is irrelevant for this thread ',' ','This action describes what to do for an incoming SIM / web message. if the mp3/message field is not blank, then the child threads will only be spawned IF the text is found in the message')");
#$db->do("INSERT INTO Action VALUES (14,'Callback SIM', 'wait ','until sending ','This action describes an outbound callback SIM message')");
$db->do("INSERT INTO Action VALUES (15,'Stash First Counts', ' ','not relevent','This action describes storing the most recent recieved message onto the stash')");
$db->do("INSERT INTO Action VALUES (16,'Active Child Threads', ' ','not relevent','This action sets only its child threads to be active for its Twilio Number')");
#$db->do("INSERT INTO  DefaultInboundThread values ('SIM',1) ");


my $all = $db->selectall_arrayref("SELECT * FROM Thread");





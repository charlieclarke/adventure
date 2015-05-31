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
my $defaultSID = $cfg->param('twilio.twilioAcountSid');
my $defaultAuthToken = $cfg->param('twilio.twilioAuthToken');

print "got sid=$defaultSID token=$defaultAuthToken\n";

my $db = DBI->connect("dbi:SQLite:$db_location", "", "",
{RaiseError => 1, AutoCommit => 1});


$db->do("DROP TABLE IF EXISTS Clone ");
$db->do("DROP TABLE IF EXISTS CloneTwilio ");
$db->do("DROP TABLE IF EXISTS Scene");

$db->do("CREATE TABLE Clone (CloneID INTEGER PRIMARY KEY, CloneName TEXT, UserName TEXT, Password TEXT, MP3URL TEXT)");
$db->do("CREATE TABLE CloneTwilio (CloneTwilioID INTEGER PRIMARY KEY, twilioAcountSID TEXT, twilioAuthToken TEXT)"); #constraint - clonetwilioid = cloneid
$db->do("CREATE TABLE Scene (SceneID INTEGER PRIMARY KEY, CloneID INTEGER, SceneName TEXT, isActive INTEGER)"); #constraint - clonetwilioid = cloneid

$db->do("INSERT INTO  Clone values (1,'Default','user1','user1','') ");
$db->do("INSERT INTO  CloneTwilio values (1,'$defaultSID','$defaultAuthToken') ");
$db->do("INSERT INTO  Scene values (1,1,'Default Scene',1) ");



#uncomment when making for the first time...
$db->do("alter table Thread add column SceneID INTEGER default 1");
$db->do("alter table Groups add column CloneID INTEGER default 1");
$db->do("alter table Number add column CloneID INTEGER default 1");
$db->do("alter table TNumber add column CloneID INTEGER default 1");



my $all = $db->selectall_arrayref("SELECT * FROM Thread");





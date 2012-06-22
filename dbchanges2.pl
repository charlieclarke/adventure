#!/opt/local/bin/perl
#
#
#this script adds in support for multiple twilio numbers...
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

$db->do("alter table Thread add column TNumberID INTEGER default 1");
$db->do("create table TNumber (TNumberID INTEGER PRIMARY KEY, TNumber TEXT, TNumberName TEXT, IsActive INTEGER)");
$db->do("insert into TNumber (TNumber , TNumberName, IsActive) values ('+44','default',1)");

my $all = $db->selectall_arrayref("SELECT * FROM Thread");





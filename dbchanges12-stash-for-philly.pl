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

$db->do("delete from Action where actiontypeid >= 20 and actiontypeid <= 25");


$db->do("INSERT INTO Action VALUES (20,'Reset Stash to 0', ' ','not relevent','This action sets the stash to numerical 0')");
$db->do("INSERT INTO Action VALUES (21,'Increment Stash', ' ','not relevent','increments the stash')");
$db->do("INSERT INTO Action VALUES (22,'Decrement Stash', ' ','not relevent','decrements the stash')");
$db->do("INSERT INTO Action VALUES (23,'Filter if stash &gt;', ' ','not relevent','triggers children if the stashed value is greater than the filter, The syntax is that the mp3 field is stashname,filterfalue')");
$db->do("INSERT INTO Action VALUES (24,'Filter if stash =', ' ','not relevent','triggers children if the stashed value is equal to the filter, The syntax is that the mp3 field is stashname,filterfalue')");
$db->do("INSERT INTO Action VALUES (25,'Filter if stash &lt;', ' ','not relevent','triggers children if the stashed value is greater than the filter, The syntax is that the mp3 field is stashname,filterfalue')");





my $all = $db->selectall_arrayref("SELECT * FROM Thread");





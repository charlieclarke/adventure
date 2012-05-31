#!/opt/local/bin/perl
#
#

use DBI;
use DateTime;
use DateTime::Format::SQLite;

use WWW::Twilio::API;


my $ACTION_PLAY_MP3_RESPWAN = 1;
my $ACTION_PLAY_MP3_NORESPAWN = 2;
my $ACTION_GENERATE_PLAY_MP3 = 3;


#sort out configs
use Config::Simple;

my $cfg = new Config::Simple('config.local');
my $db_location = $cfg->param('database.databasepath');

my $twilio_account_sid = $cfg->param('twilio.twilioAcountSid');
my $twilio_auth_token = $cfg->param('twilio.twilioAuthToken');
my $twilio_from_number = $cfg->param('twilio.twilioFromNumber');
my $php_server = $cfg->param('web.phpServer');

print "db location from config = $db_location\n";

my $sharedsecret=$cfg->param('web.sharedSecret');

#initialize connection to twilio - remember to put in the correct credentials

my $twilio = WWW::Twilio::API->new(AccountSid => $twilio_account_sid,
                                     AuthToken  => $twilio_auth_token);


#initialize local database for tracking of timeline etc.

my $db = DBI->connect("dbi:SQLite:$db_location", "", "",
{RaiseError => 1, AutoCommit => 1});

$time_now = DateTime->now;
$time_now_sqllite  = DateTime::Format::SQLite->format_datetime($time_now);

print_timeline();
init();
print_timeline();

sync_time();


run_timeline();


exit(0);

sub sync_time {

	$time_now = DateTime->now;
	$time_now_sqllite = DateTime::Format::SQLite->format_datetime($time_now);

}
sub init {

	$db->do("delete from TimeLine");
#id INTEGER PRIMARY KEY, ActionType INTEGER, DestNumber TEXT, mp3Name TEXT, StartTimeHour INTEGER, StartTimeMinute INTEGER, StopTimeHour INTEGER, StopTimeMinute INTEGER, FrequencyMinutes INTEGER)
	my $all = $db->selectall_arrayref("select id, actionType, mp3Name, StartTimeHour, StartTimeMinute, StopTimeHour, StopTimeMinute from Thread");

	my $sth = $db->prepare("INSERT INTO TimeLine VALUES (?,?,?,?,?,?,?)");

	foreach my $row (@$all) {
                my ($threadID, $actionType, $mp3Name, $startTimeHour, $startTimeMinute, $stopTimeHour, $stopTimeMinute) = @$row;


		#TODO = time checks

		$sth->execute(undef, $threadID, $time_now_sqllite, 0, undef, "initial entry",undef);

        }

}


sub mark_timeline_complete {
	my ($id, $notes) = @_;

	my $sth = $db->prepare("UPDATE TimeLine set Completed=1, CompletedTime=?, Notes=? where id=?");
	$sth->execute($time_now_sqllite, $notes, $id);

}


sub insert_timeline {
	my ($threadID, $startTime, $comm) = @_;

	my $sth = $db->prepare("INSERT INTO TimeLine VALUES (?,?,?,?,?,?,?)");
	my $startTimeSqllite = DateTime::Format::SQLite->format_datetime($startTime);
	$sth->execute(undef, $threadID, $startTimeSqllite, 0, undef, $comm,undef);

}


sub print_timeline {
	my $all = $db->selectall_arrayref("select id, ThreadID, ActivityTime, Completed, CompletedTime, Description, Notes from TimeLine order by ActivityTime");

	print "--------\n";
	foreach my $row (@$all) {
		my ($id, $threadID, $activityTime, $completed, $completedTime, $description, $notes) = @$row;

		$printableTime = scalar($activityTime);
		print "$id\t$threadID,$printableTime\t$completed\t$completedTime\t$description\t$notes\n";
	}


}


sub run_timeline {


	my $sth = $db->prepare("select TimeLine.id, TimeLine.ThreadID, TimeLine.ActivityTime, TimeLine.Completed, TimeLine.CompletedTime, TimeLine.Description, TimeLine.Notes, Thread.ActionType, Thread.mp3Name, Thread.DestNumber, Thread.FrequencyMinutes,Thread.StartTimeHour, Thread.StopTimeHour,Thread.ChildThreadID from TimeLine, Thread where TimeLine.Completed = 0 and TimeLine.ActivityTime < ? and TimeLine.ThreadID = Thread.id order by TimeLine.ActivityTime");


	while(1) {
		$sth->execute($time_now_sqllite);

		my $all = $sth->fetchall_arrayref();

		if (scalar(@$all) > 0) {
			print "\n";
			foreach my $row (@$all) {
				my ($id, $threadID, $activityTime, $completed, $completedTime, $description, $notes, $actionType, $mp3Name, $destNumber, $frequency,$startTimeHour,$stopTimeHour,$childThreadID) = @$row;

				print "got task $id with threadID $threadID: $description - actionType $actionType, mp3 $mp3Name\n";

				if ($actionType eq 1) {
					outbound_mp3_call_respawn($id, $threadID, $destNumber, $mp3Name, $frequency);

				} elsif ($actionType eq 2) {
					outbound_mp3_call($destNumber, $threadID);
				} elsif ($actionType eq 3) {
					generate_items($id, $threadID, $childThreadID, $frequency, $startTimeHour, $stopTimeHour);
				}
				
				mark_timeline_complete($id,"finished OK");	

				
			print_timeline();
			}
		} else {
			print 'x';
		}

		sleep(1);
		sync_time();
	}
}
sub generate_items {

	my ($id, $threadID, $childThreadID, $frequency, $startTimeHour, $stopTimeHour) = @_;

	#work out minutes

	my @candidateMinutes = split /,/,$frequency;
	my @minutes;

	print "generating minutes: ";

	foreach my $min (@candidateMinutes) {
	
		if ($min =~ /^\d+$/) {
			print $min . ' ';
			push @minutes, $min;
		} else {
			print "($min) ";
		}
	}
	print "\n";

	#midnight today
	my $midnight_today = $time_now->clone();
	my $midnight_today = $midnight_today->subtract(hours => $time_now->hour, minutes=>$time_now->minute, seconds=>$time_now->second);
	print "time_now - $time_now midnight_today = $midnight_today \n";	

	#idnight tomorrow
	my $midnight_tomorrow = $midnight_today->clone();
	my $midnight_tomorrow = $midnight_tomorrow->add(hours => 24);

	#insert todays minutes
	print "create activity stream for $startTimeHour to $stopTimeHour \n";

	
	for (my $h = $startTimeHour; $h < $stopTimeHour; $h++) {

		print "inserting minutes for $h:";
		foreach my $m (@minutes) {
			my $activityTime = DateTime->new( year => $midnight_today->year,
                          month      => $midnight_today->month,
                          day        => $midnight_today->day,
                          hour       => $h,
                          minute     => $m,
                          second     => 0,
                           );

			my $cmp = DateTime->compare_ignore_floating($activityTime, $time_now);
			if ($cmp>0) {
				print "$m ";

				insert_timeline ($childThreadID, $activityTime,"generated child of ($id)" );
			} else {
			}
		}

			print "\n";
	}
		

	#respawn midnight tomorrow
	insert_timeline ($threadID, $midnight_tomorrow, "respawn generator child of ($id)");
	


}

sub outbound_mp3_call_respawn {

	my ($id, $threadID, $destNumber, $mp3Name, $frequency) = @_;
	print "MAKE CALL: $destNumber, $mp3Name\n";


	#make the phone call using twilio API
	outbound_mp3_call($destNumber, $threadID);

	$respawn_time = $time_now->add(minutes=>$frequency);


	$respawn_time_sqllite = DateTime::Format::SQLite->format_datetime($respawn_time);

	insert_timeline($threadID, $respawn_time, "autogen child of ($id)");


}

sub outbound_mp3_call {
	my ($destNumber, $threadID) = @_;

	print "CALLING $destNumber due to thread $threadID \n";
	$url = $php_server . "timeline-caller.php?threadID=${threadID}&secret=${sharedsecret}";
	print "URL: $url\n";
	

	my $call = 0;
	if ($call eq 1) {
		$response = $twilio->POST( 'Calls',
					 From => $twilio_from_number,
				      To   => $destNumber,
					   Url  => $url );

		print $response->{content};
	}

}




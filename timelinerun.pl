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

my $twilio_account_sid = $cfg->param('twilio.twilioAcountSid');
my $twilio_auth_token = $cfg->param('twilio.twilioAuthToken');
my $twilio_from_number = $cfg->param('twilio.twilioFromNumber');
my $php_server = $cfg->param('web.phpServer');
print "php server is $php_server\n";

print "db location from config = $db_location\n";

my $sharedsecret=$cfg->param('web.sharedSecret');

#initialize connection to twilio - remember to put in the correct credentials

my $twilio = WWW::Twilio::API->new(AccountSid => $twilio_account_sid,
                                     AuthToken  => $twilio_auth_token);


$internationalPhoneRegion = '+44';


#initialize local database for tracking of timeline etc.

my $db = DBI->connect("dbi:SQLite:$db_location", "", "",
{RaiseError => 1, AutoCommit => 1});

$time_now = DateTime->now;
$time_now_sqllite  = DateTime::Format::SQLite->format_datetime($time_now);

print_timeline();
#init();
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

	my $sth = $db->prepare("INSERT INTO TimeLine(ThreadId, ActivityTime, Completed, CompletedTime, Description, Notes, AdditionalNumberID) VALUES (?,?,?,?,?,?,0)");
	my $startTimeSqllite = DateTime::Format::SQLite->format_datetime($startTime);
	$sth->execute($threadID, $startTimeSqllite, 0, undef, $comm,undef);

}

sub insert_timeline_offset {
        my ($threadID, $offset, $comm,$additionalNumberID) = @_;
	my $sql = "INSERT INTO TimeLine(ThreadId, ActivityTime, Completed, CompletedTime, Description, Notes, AdditionalNumberID) VALUES (?,datetime('now','+$offset minutes'),?,?,?,?,?)";	


	print "sq; is $sql\n";

        my $sth = $db->prepare($sql);
        $sth->execute($threadID,  0, undef, $comm,undef,$additionalNumberID);

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


	my $sth = $db->prepare("select TimeLine.id, TimeLine.ThreadID, TimeLine.ActivityTime, TimeLine.Completed, TimeLine.CompletedTime, TimeLine.Description, TimeLine.Notes, Thread.ActionType, Thread.mp3Name, Thread.DestNumber, Thread.FrequencyMinutes,Thread.StartTimeHour, Thread.StopTimeHour,Thread.ChildThreadID, Number.NumberID, Number.Number, TNumber.TNumber from TimeLine, Thread,Number, TNumber where TimeLine.Completed = 0 and Thread.TNumberID = TNumber.TNumberID and TimeLine.ActivityTime < ? and TimeLine.ThreadID = Thread.id and TimeLine.AdditionalNumberID = Number.NumberID order by TimeLine.ActivityTime");

	my $hbSql = $db->prepare("update HeartBeat set HeartBeatTime = DateTime('now') where HeartBeatName='LastTimeLine'");

	

	while(1) {

		$hbSql->execute();
		
		$sth->execute($time_now_sqllite);

		my $all = $sth->fetchall_arrayref();

		if (scalar(@$all) > 0) {
			print "\n";
			foreach my $row (@$all) {
				my ($id, $threadID, $activityTime, $completed, $completedTime, $description, $notes, $actionType, $mp3Name, $destNumber, $frequency,$startTimeHour,$stopTimeHour,$childThreadID,$additionalNumberID, $additionalNumber,$twilionumber) = @$row;

				print "got task $id with threadID $threadID: $description - actionType $actionType, mp3 $mp3Name\n";

				if ($actionType eq 1) {
					outbound_mp3_group_call_respawn($id, $threadID, $destNumber, $mp3Name, $frequency);

				} elsif ($actionType eq 2) {
					outbound_mp3_group_call($destNumber, $threadID,$id,$twilionumber);
				} elsif ($actionType eq 3) {
					generate_items($id, $threadID, $childThreadID, $frequency, $startTimeHour, $stopTimeHour);
				} elsif ($actionType eq 4) {
					outbound_group_sms($destNumber, $mp3Name,$id,$threadID,$childThreadID,$additionalNumberID,$twilionumber);
				} elsif ($actionType eq 7) {
                                        outbound_callback_mp3($additionalNumberID, $additionalNumber, $mp3Name,$id,$threadID,$twilionumber);
				} elsif ($actionType eq 8) {
					#place sms to the additional number
					outbound_sms ($additionalNumber, $mp3Name,$id,$additionalNumberID,$threadID, $childThreadID, 1,$twilionumber);
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

sub outbound_mp3_group_call_respawn {

	my ($id, $threadID, $destGroupID, $mp3Name, $frequency,$twilionumber) = @_;
	print "MAKE CALL: $destGroupID, $mp3Name\n";


	#get the numbers in the group


	print "making group call to group id $destGroupID\n";
         my $all = $db->selectall_arrayref("select Number from GroupNumber, Number where GNNumberID = Number.NumberID and GNGroupID = " . $destGroupID);


        foreach my $row (@$all) {
		 my ($destNumber,$numberID) = @$row;

                #make the phone call using twilio API
                 outbound_mp3_call($destNumber, $threadID,$id,$numberID,$twilionumber);

        }
	

	if ($frequency > 0) {

		$respawn_time = $time_now->add(minutes=>$frequency);


		$respawn_time_sqllite = DateTime::Format::SQLite->format_datetime($respawn_time);

		insert_timeline($threadID, $respawn_time, "autogen child of ($id)");
	} else {
		#you cannot have a respawn of 0 - causes an expensive infinite loop
		print "respawn is bad with freq 0\n";
	}


}

sub outbound_mp3_group_call {

	my ($destGroupID, $threadID,$timeLineID,$twilionumber) = @_;

	#get the numbers in the group

	print "making group mp3 call to group id $destGroupID\n";

         my $all = $db->selectall_arrayref("select Number, NumberID from GroupNumber, Number where GNNumberID = Number.NumberID and GNGroupID = " . $destGroupID);


        foreach my $row (@$all) {
                my ($destNumber,$numberID) = @$row;

                #make the phone call using twilio API
                outbound_mp3_call($destNumber, $threadID,$timeLineID,$numberID,$twilionumber);

        }


}

sub outbound_callback_mp3 {

	my ($additionalNumberID, $additionalNumber, $mp3Name,$timeLineID,$threadID,$twilionumber) = @_;

	my $callTrackID = insert_new_calltrack($threadID, $timeLineID, $additionalNumberID, $response->{content}, 'call not sent');
        print "PLACE CALLBACK: calltrackID = $callTrackID\n";


	place_mp3_call($additionalNumber, $threadID, $callTrackID,$twilionumber);


}
sub outbound_mp3_call {
	my ($destNumber, $threadID,$timeLineID,$numberID,$twilionumber) = @_;

	my $callTrackID = insert_new_calltrack($threadID, $timeLineID, $numberID, $response->{content}, 'call not sent');
        print "calltrackID = $callTrackID\n";

	place_mp3_call($destNumber, $threadID, $callTrackID,$twilionumber);

}

sub place_mp3_call {
	my ($destNumber, $threadID, $callTrackID,$twilionumber) = @_;


	print "CALLING $destNumber from $twilionumber due to thread $threadID \n";
	$url = $php_server . "timeline-caller.php?threadID=${threadID}&secret=${sharedsecret}&CallTrackID=${callTrackID}";
	print "URL: $url\n";
	

	if (is_number_within_region($destNumber)) { 
		my $call = 1;
		if ($call eq 1) {
			$response = $twilio->POST( 'Calls',
						 From => $twilionumber,
					      To   => $destNumber,
						   Url  => $url );

			print $response->{content};
			update_calltrack_twilio($callTrackID, $response->{content}, 'Call sent');
		}
		} else {

		update_calltrack_twilio($callTrackID, $response->{content}, 'Call not sent - number not in region');

	}


}

sub outbound_group_sms {

	 my ($destGroupID, $message, $timeLineID,$threadID,$childThreadID,$additionalNumberID,$twilionumber) = @_;

        #get the numbers in the group



	 print "making group SMS to group id $destGroupID\n";
	 my $all = $db->selectall_arrayref("select Number,NumberID from GroupNumber, Number where GNNumberID = Number.NumberID and GNGroupID = " . $destGroupID);


        foreach my $row (@$all) {
                my ($destNumber, $destNumberID) = @$row;

                #make the phone call using twilio API
                outbound_sms($destNumber, $message, $timeLineID, $destNumberID,$threadID,$childThreadID,0,$twilionumber);

        }

	#now we have to add any child threads
	@childThreadIDs = split (/,/,$childThreadID);


	foreach my $childID (@childThreadIDs) {

		 my $all = $db->selectall_arrayref("select FrequencyMinutes from Thread where id = $childID");


		foreach my $row (@$all) {
			 my ($freq) = @$row;

		
			insert_timeline_offset($childID, $freq , "inserted as child of SMS thread $threadID",$additionalNumberID);

		}

	}
	

}


sub is_number_within_region {

        my ($number) = @_;

	my $numberRegEx = $internationalPhoneRegion;
	$numberRegEx =~ s/\+/\\+/;
	print $numberRegEx . "\n";

        return $number =~ /^$numberRegEx/;


}



sub outbound_sms {
	my ($destNumber, $message,$timeLineID,$numberID,$threadID,$childThreadID, $spawnChild,$twilionumber) = @_;

	print "send SMS $message from $twilionumber to $destNumber\n";
	my $callTrackID = insert_new_calltrack($threadID, $timeLineID, $numberID, $response->{content}, 'SMS not sent');
	print "calltrackID = $callTrackID\n";

	if (is_number_within_region($destNumber)) {
		my $sms = 1;
		if ($sms eq 1) {

			$response = $twilio->POST('SMS/Messages',
				    From => $twilionumber,
				    To   => $destNumber,
				    Body => $message );

			print $response->{content};

			update_calltrack_twilio($callTrackID, $response->{content}, 'SMS sent');

		}
	} else {
		update_calltrack_twilio($callTrackID, $response->{content}, 'SMS not sent - number not in region');
	}

	if ($spawnChild > 0) {

		#now we have to add any child threads
		@childThreadIDs = split (/,/,$childThreadID);
		foreach my $childID (@childThreadIDs) {
		
	   	     my $all = $db->selectall_arrayref("select FrequencyMinutes from Thread where id = $childID");
		
		     foreach my $row (@$all) {
			   my ($freq) = @$row;
		           insert_timeline_offset($childID, $freq , "inserted as callback child of SMS thread $threadID",$numberID);
			}
		}

	}
}
sub insert_new_calltrack {

	my ($threadID, $timeLineID, $numberID, $twilioID, $textStatus) = @_;



	$sql = "INSERT INTO CallTrack (IsOutbound, TrackNumberID, ThreadID, TimeLineID, TrackTime, TwilioID , TwilioFollowup, StatusText) values (1,?,?,?,DATETIME('now'),?,?,?)";


	print "adding call track for $threadID,$timeLineID,$numberID, $twilioID, $textStatus\n";


	my $sth = $db->prepare($sql);
        $sth->execute($numberID, $threadID, $timeLineID, $twilioID, 0, $textStatus);


	$sql = "select max(TrackID) from CallTrack where TimeLineID = $timeLineID and TrackNumberID=$numberID";

	print "getting caltrackID with $sql\n";

	my $all = $db->selectall_arrayref($sql);


	my $callTrackID = 0;
        foreach my $row (@$all) {
                  ($callTrackID) = @$row;

	}

	return($callTrackID);	
}
sub update_calltrack_twilio {
	my ($callTrackID, $twilioID, $status) = @_;

	$sql = "update CallTrack set TwilioID = ?, StatusText = ? where TrackID = ?";
	my $sth = $db->prepare($sql);
        $sth->execute($twilioID, $status,$callTrackID);


}

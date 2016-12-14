#!/opt/local/bin/perl
##
##
#
use DBI;
use DateTime;
use DateTime::Format::SQLite;
use Config::Simple;

my $hostname = `/bin/hostname`;
print "got hostname of $hostname\n";
if ($hostname =~ /local/) {
        $configlocation = "/var/tmp/config.local";
} else {
	$configlocation = "/var/cache/timeline/config.local";
}
#sort out configs

my $cfg = new Config::Simple($configlocation);
my $db_location = $cfg->param('database.databasepath');
#
my $twilio_account_sid = $cfg->param('twilio.twilioAcountSid');
my $twilio_auth_token = $cfg->param('twilio.twilioAuthToken');
my $twilio_from_number = $cfg->param('twilio.twilioFromNumber');
my $php_server = $cfg->param('web.phpServer');
print "php server is $php_server\n";

print "db location from config = $db_location\n";

my $db = DBI->connect("dbi:SQLite:$db_location", "", "", {RaiseError => 1, AutoCommit => 1});


$actionKickOff = 11;
$actionOutboundSIM = 14;
$actionInboundSIM = 13;
$actionStash = 15;
$actionActivate = 16;


$qn = 1;
while(<>) {


        $line = $_;
        chomp $line;

        if ($line =~ /^(.*?),\"?(.*?)\"?$/ ) {

                $desc = $1;
                $cont = $2;

                $cont =~ s/\"/'/g;
                $parts{$desc} = $cont;

        if ($desc eq "RD") {
        $qk = "Q$qn";
        $questionText = "Question $qn: " . $parts{$qk};
        $A = $parts{"A"};
        $B = $parts{"B"};
        $C = $parts{"C"};
        $D = $parts{"D"};
        $questionText = $questionText . "**A. $A**B. $B**C. $C**D. $D";
        $questionAResponse = $parts{"RA"};
        $questionBResponse = $parts{"RB"};
        $questionCResponse = $parts{"RC"};
        $questionDResponse = $parts{"RD"};

        print "Question Text\t: $questionText\n\t$questionAResponse\n\t$questionBResponse\n\t$questionCResponse\n\t$questionDResponse\n";
	make_question($qn, $questionText, $questionAResponse, $questionBResponse, $questionCResponse, $questionDResponse);
        %parts = ();
        $qn++;
        }
        } else {
        }



}



sub make_question{

my ($questionNumber, $questionText, $questionAResponse, $questionBResponse, $questionCResponse, $questionDResponse) = @_;

#add in the HIDES for answers etc.
#

$questionAResponse .= "HIDE";
$questionBResponse .= "HIDE";
$questionCResponse .= "HIDE";
$questionDResponse .= "HIDE";

$offset = 100;

$id = $offset + $questionNumber * 20;

$kickOffID = $id;
$activateID = ++$id;
$sendQuestionID = ++$id;
$AinboundResponseID = ++$id;
$AanswerResponseID = ++$id;
$AstashID = ++$id;


$BinboundResponseID = ++$id;
$BanswerResponseID = ++$id;
$BstashID = ++$id;


$CinboundResponseID = ++$id;
$CanswerResponseID = ++$id;
$CstashID = ++$id;

$DinboundResponseID = ++$id;
$DanswerResponseID = ++$id;
$DstashID = ++$id;

$DestNumber = 0;
$StartTimeHour = 0;
$StartTimeMinute = 0;
$StopTimeHour = 23;
$StopTimeMinute = 59;
$FrequencyMinutes = 0;
$TNumberID = 16;
$Active = 0;

#kick off children thread
$id = $kickOffID;
$threadDescription = "Q$questionNumber Send";
$actionType =  $actionKickOff;
#
$mp3Name = "";
$childThreadID = "$activateID,$sendQuestionID";

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#activate children
$id = $activateID;
$threadDescription = "Q$questionNumber activate children";
$actionType = $actionActivate;
$mp3Name = "";
$childThreadID = "$kickOffID,$activateID,$sendQuestionID,$AinboundResponseID,$AanswerResponseID,$AstashID,$BinboundResponseID,$BanswerResponseID,$BstashID,$CinboundResponseID,$CanswerResponseID,$CstashID,$DinboundResponseID,$DanswerResponseID,$DstashID"; 


do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#send question

$id = $sendQuestionID;
$threadDescription = "Q$questionNumber send question";
$actionType = $actionOutboundSIM;
$mp3Name = $questionText;
$childThreadID = ""; 

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);


#inbound answer A 

$questionResponse = $questionAResponse;
$questionInboundThreadID = $AinboundResponseID;
$questionReplyThreadID = $AanswerResponseID;
$questionStashThreadID = $AstashID;
$question = 'A';
$questionFilter = "ANSWER $question";
#inbound filter on answer

$id = $questionInboundThreadID;
$threadDescription = "Q$questionNumber anwer $question inbound filter";
$actionType = $actionInboundSIM;
$mp3Name = $questionFilter;
$childThreadID = "$questionReplyThreadID,$questionStashThreadID"; 

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#inbound reply on answer
$id = $questionReplyThreadID;
$threadDescription = "Q$questionNumber answer $question outbound response";
$actionType = $actionOutboundSIM;
$mp3Name = $questionResponse;
$childThreadID = "";

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#inbound stash reply
$id = $questionStashThreadID;
$threadDescription = "Q$questionNumber answer $question stash";
$actionType = $actionStash;
$mp3Name = "Q$questionNumber";
$childThreadID = "";

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#end of inbound answer A

#inbound answer B 

$questionResponse = $questionBResponse;
$questionInboundThreadID = $BinboundResponseID;
$questionReplyThreadID = $BanswerResponseID;
$questionStashThreadID = $BstashID;
$question = 'B';
$questionFilter = "ANSWER $question";
#inbound filter on answer

$id = $questionInboundThreadID;
$threadDescription = "Q$questionNumber anwer $question inbound filter";
$actionType = $actionInboundSIM;
$mp3Name = $questionFilter;
$childThreadID = "$questionReplyThreadID,$questionStashThreadID"; 

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#inbound reply on answer
$id = $questionReplyThreadID;
$threadDescription = "Q$questionNumber answer $question outbound response";
$actionType = $actionOutboundSIM;
$mp3Name = $questionResponse;
$childThreadID = "";

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#inbound stash reply
$id = $questionStashThreadID;
$threadDescription = "Q$questionNumber answer $question stash";
$actionType = $actionStash;
$mp3Name = "Q$questionNumber";
$childThreadID = "";

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#end of inbound answer B

#inbound answer C 

$questionResponse = $questionCResponse;
$questionInboundThreadID = $CinboundResponseID;
$questionReplyThreadID = $CanswerResponseID;
$questionStashThreadID = $CstashID;
$question = 'C';
$questionFilter = "ANSWER $question";
#inbound filter on answer

$id = $questionInboundThreadID;
$threadDescription = "Q$questionNumber anwer $question inbound filter";
$actionType = $actionInboundSIM;
$mp3Name = $questionFilter;
$childThreadID = "$questionReplyThreadID,$questionStashThreadID"; 

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#inbound reply on answer
$id = $questionReplyThreadID;
$threadDescription = "Q$questionNumber answer $question outbound response";
$actionType = $actionOutboundSIM;
$mp3Name = $questionResponse;
$childThreadID = "";

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#inbound stash reply
$id = $questionStashThreadID;
$threadDescription = "Q$questionNumber answer $question stash";
$actionType = $actionStash;
$mp3Name = "Q$questionNumber";
$childThreadID = "";

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#end of inbound answer C

#inbound answer D 

$questionResponse = $questionDResponse;
$questionInboundThreadID = $DinboundResponseID;
$questionReplyThreadID = $DanswerResponseID;
$questionStashThreadID = $DstashID;
$question = 'D';
$questionFilter = "ANSWER $question";
#inbound filter on answer

$id = $questionInboundThreadID;
$threadDescription = "Q$questionNumber anwer $question inbound filter";
$actionType = $actionInboundSIM;
$mp3Name = $questionFilter;
$childThreadID = "$questionReplyThreadID,$questionStashThreadID"; 

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#inbound reply on answer
$id = $questionReplyThreadID;
$threadDescription = "Q$questionNumber answer $question outbound response";
$actionType = $actionOutboundSIM;
$mp3Name = $questionResponse;
$childThreadID = "";

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#inbound stash reply
$id = $questionStashThreadID;
$threadDescription = "Q$questionNumber answer $question stash";
$actionType = $actionStash;
$mp3Name = "Q$questionNumber";
$childThreadID = "";

do_insert($id, $threadDescription, $actionType, $DestNumber, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

#end of inbound answer D

} #end of sub make question...





sub do_insert {

	my ($id, $threadDescription, $actionType, $DestNumner, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active) = @_;


	$sql = "INSERT INTO Thread(id, ThreadDescription, ActionType, DestNumber, mp3Name, StartTimeHour, StartTimeMinute, StopTimeHour, StopTimeMinute, FrequencyMinutes, ChildThreadID, TNumberID, Active) values (?,?,?,?,?,?,?,?,?,?,?,?,?)";

	my $sth = $db->prepare($sql);
	$sth->execute($id, $threadDescription, $actionType, $DestNumner, $mp3Name, $StartTimeHour, $StartTimeMinute, $StopTimeHour, $StopTimeMinute, $FrequencyMinutes, $childThreadID, $TNumberID, $Active);

}

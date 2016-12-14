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
$questionText = "Question 1:**Here's how this game plays. You answer each question by making your choice A to D. If you like, you can add a comment. Is this clear?**A. Yes**B. No**C. I think so**D It's clear but I reckon there's something else to watch out for";
$questionAResponse = "You answered in time!";
$questionBResponse = "You answered in time!";
$questionCResponse = "You answered in time!";
$questionDResponse = "You answered in time!";

$questionNumber = 1;

make_question($questionNumber, $questionText, $questionAResponse, $questionBResponse, $questionCResponse, $questionDResponse);


$questionNumber = 2;
$questionText = "Question 2:**Do you believe the host saying that it doesn't matter if you pass?**A. No**B. Yes.**C. It's hard to read our host.**D. Pass";
$questionAResponse = "It really doesn't matter for winning the game but the more you can answer the better we can place you";
$questionBResponse = "Yes. It really doesn't matter for winning the game, but the more you can answer the better we can place you.";
$questionCResponse = "I agree. But he has a lovely beard and here he speaks the truth. You can pass.";
$questionDResponse = "Aren't you the tricksy one? Do I think you're right? Pass.";

make_question($questionNumber, $questionText, $questionAResponse, $questionBResponse, $questionCResponse, $questionDResponse);


$questionNumber = 3;
$questionText = "Question 3:**Did you notice what flashed on the big screens a second ago?**A. No, I'm always paying attention to the action.**B An elephant.**C. A giraffe.**D. A rabbit.";
$questionAResponse = "That's wise. But try and keep an eye out for the screens too if you can";
$questionBResponse = "Close. But it's good you're keeping an eye on the screens and the action";
$questionCResponse = "Close. But it's good you're keeping an eye on the screens and the action";
$questionDResponse = "Bingo. Keep an eye on the screens and an eye on the action";

make_question($questionNumber, $questionText, $questionAResponse, $questionBResponse, $questionCResponse, $questionDResponse);


$questionNumber = 4;
$questionText = "Question 4:**How do you feel about the rules of this game being mysterious?**A. Mostly excited.**B. Mostly annoyed.**C. A  little intrigued.**D. It's what I'd expect.";
$questionAResponse = "That's good to know, thanks.";
$questionBResponse = "That's good to know, thanks.";
$questionCResponse = "That's good to know, thanks.";
$questionDResponse = "That's good to know, thanks.";

make_question($questionNumber, $questionText, $questionAResponse, $questionBResponse, $questionCResponse, $questionDResponse);

$questionNumber = 5;
$questionText = "Question 5:**How much do you care about winning a game?**A. I love to win, by any means necessary..**B. I love to win, but we must follow the rules.**C. I like to win but how well we play is also important.**D. I don't care as long as everyone has fun.";
$questionAResponse = "That's most revealing";
$questionBResponse = "That's most revealing";
$questionCResponse = "That's most revealing";
$questionDResponse = "That's most revealing";

make_question($questionNumber, $questionText, $questionAResponse, $questionBResponse, $questionCResponse, $questionDResponse);


$questionNumber = 6;
$questionText = "Question 6:**Which do you suspect will be most important for winning this game?**A. Answering a particular number of questions, whether right or wrong.**B. Only giving the right answers to questions which have a right answer.**C. Adding interesting comments to the answers.**D. It won't be about these questions but everything else we play.";
$questionAResponse = "You're right";
$questionBResponse = "You're right.";
$questionCResponse = "You're right.";
$questionDResponse = "You're right.";

make_question($questionNumber, $questionText, $questionAResponse, $questionBResponse, $questionCResponse, $questionDResponse);

$questionNumber = 7;
$questionText = "Question 7:**Do you think that I said \"you're right\" to everyone? Take a look around before answering.**A. Definitely yes.**B. Definitely not.**C. I'm not sure, but I'm smiling.**D. I'm not sure, but other people seem to be smiling.";
$questionAResponse = "You might be right, but I'm not saying.";
$questionBResponse = "You might be right, but I'm not saying.";
$questionCResponse = "You might be right, but I'm not saying.";
$questionDResponse = "You might be right, but I'm not saying.";

make_question($questionNumber, $questionText, $questionAResponse, $questionBResponse, $questionCResponse, $questionDResponse);

$questionNumber = 8;
$questionText = "Question 8:**Which is most like you in play?**A. Someone who dives right into playing.**B. Someone who looks for other people and then dives in with them.**C. Someone who prefers to watch other people playing before then diving in.**D. Someone who prefers to watch rather than playing unless absolutely comfortable.";
$questionAResponse = "That's good to know, and you can do as you like.";
$questionBResponse = "That's good to know, and you can do as you like.";
$questionCResponse = "That's good to know, and you can do as you like.";
$questionDResponse = "That's good to know, and you can do as you like.";

make_question($questionNumber, $questionText, $questionAResponse, $questionBResponse, $questionCResponse, $questionDResponse);


while($questionNumber < 20) {
$questionNumber ++;
$questionText = "Question $questionNumber:**A. Option A.**B. Option B. **C. Option C. **D. Option D.";
$questionAResponse = "Q$questionNumber response for A";
$questionBResponse = "Q$questionNumber response for B";
$questionCResponse = "Q$questionNumber response for C";
$questionDResponse = "Q$questionNumber response for D";

make_question($questionNumber, $questionText, $questionAResponse, $questionBResponse, $questionCResponse, $questionDResponse);
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

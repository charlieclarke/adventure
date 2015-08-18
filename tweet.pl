#!/usr/bin/perl


use Net::Twitter::Lite::WithAPIv1_1;
use Scalar::Util 'blessed';
use Data::Dumper;

my $mssage = $ARGV[0];
my $twitterName = $ARGV[1];
my $twitterAccessToken = $ARGV[2];
my $twitterAccessTokenSecret = $ARGV[3];
my $twitterConsumerKey = $ARGV[4];
my $twitterConsumerKeySecret = $ARGV[5];


print "twitter params\n";

print $twitterName;
print "\n";
print $twitterAccessToken;

print "\n";
print $twitterAccessTokenSecret;

print "\n";

print $twitterConsumerKey;

print "\n";
print $twitterConsumerKeySecret;

print "\n";

	print "message is $mssage\n";
my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
 consumer_key        => $twitterConsumerKey,
  consumer_secret     => $twitterConsumerKeySecret,
   access_token        => $twitterAccessToken,
    access_token_secret => $twitterAccessTokenSecret,
     ssl => 1
     );
     my $result = eval { $nt->update($mssage) };

     if ( my $err = $@ ) {
      die $@ unless blessed $err && $err->isa('Net::Twitter::Lite::Error');

	print Dumper $err->http_response;

       warn "HTTP Response Code: ", $err->code, "\n",
             "HTTP Message......: ", $err->message, "\n",
             "HTTP response.....: ", $err->http_response, "\n",
             "HTTP twitter code.....: ", $err->twitter_error, "\n",
                   "Twitter error.....: ", $err->error, "\n";
                   }




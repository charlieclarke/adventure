#!/opt/local/bin/perl
##
##
#


$qn = 1;
while(<>) {


	$line = $_;
	chomp $line;

	if ($line =~ /^(.*?),\"?(.*)\"?$/ ) {

		$desc = $1;
		$cont = $2;

		$cont =~ s/\"//g;
		$parts{$desc} = $cont;

	if ($desc eq "RD") {
	$qk = "Q$qn";
	$questionText = "Question $qn:**" . $parts{$qk};
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
	%parts = ();
	$qn++;
	}
	} else {
	}
	

}
	$questionText = "Question 1:** Here's how this game plays. You answer each question by making your choice A to D. If you like, you can add a comment. Is this clear?**A. Yes**B. No**C. I think so**D It's clear but I reckon there's something else to watch out for";
	$questionAResponse = "You answered in time!";
	$questionBResponse = "You answered in time!";
	$questionCResponse = "You answered in time!";
	$questionDResponse = "You answered in time!";

	$questionNumber = 1;

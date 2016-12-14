<?php
require_once('/var/www/html/adventureweb/adventureweb/timeline-lib.php');

$machinename =  gethostname();
        if (preg_match("/local/i",$machinename)) {
                $configfile = "/var/tmp/config.local";
        } else {
                $configfile = "/var/cache/timeline/config.local";
        }

         $ini_array = parse_ini_file($configfile);
$username = $ini_array['userID'];
$password = $ini_array['password'];



	$secret = $_GET["secret"];
	$crudAction = $_GET['CRUD'];
	$triggerAction = $_GET['TRIGGER'];
	
	$local_secret = $ini_array['sharedSecret'];
	$db_location = $ini_array['databasepath'];
	$base_url = $ini_array['phpServer'];
	$instance_name = $ini_array['instanceName'];
	
	$this_url = $base_url . "/timeline-groups.php";
	

	#init database
	$db = new PDO('sqlite:'.$db_location);

$tdb = new DB($db_location);
        $tdb->init();

	#perform actions etc.

                $triggerDate= '2013-09-23 15:16:45';
                $groupID =11 ; 
                $threadID = 120;

                echo "<!-- kick off group: threadID = $threadID groupID = $groupID-->\n";
                if ($threadID > 0) {
                        #we have a valid kick to insert
                        #get all numbers in the group.

                        $objNumberArray = $tdb->getPhoneNumbersByGroupID($groupID);
                        foreach($objNumberArray as $objNumber) {
                                $tdb->insertToTimeLineTime($threadID, $triggerDate, $objNumber->NumberID,"sent from monitor page as part of group $groupID");
                        }

                }


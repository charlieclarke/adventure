while :
	do
		echo 'starting timeine again'
		date
		./timelinerun.pl >>/var/tmp/run.log  2>&1 
done


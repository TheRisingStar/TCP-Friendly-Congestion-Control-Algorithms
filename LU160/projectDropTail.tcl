#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows
$ns color 0 Blue
$ns color 1 Red

#Open the nam trace file
set nf [open DropTail.nam w]
set f [open DropTail.tr w]
$ns trace-all $f
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
        global ns nf f
        $ns flush-trace
	#Close the trace file
		close $f
        close $nf
	#Execute nam on the trace file
        
        exit 0
}

#Create 16 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]
set n11 [$ns node]
set n12 [$ns node]
set n13 [$ns node]
set n14 [$ns node]
set n15 [$ns node]

#Create links between the nodes
#Senders
$ns duplex-link $n0 $n6 1Mb 10ms DropTail
$ns duplex-link $n1 $n6 1Mb 10ms DropTail
$ns duplex-link $n2 $n6 1Mb 10ms DropTail
$ns duplex-link $n3 $n6 1Mb 10ms DropTail
$ns duplex-link $n4 $n7 1Mb 10ms DropTail
$ns duplex-link $n5 $n7 1Mb 10ms DropTail
#Routers
#NEED TO SUPPORT AGGREGATE SENDER BANDWIDTH
$ns duplex-link $n6 $n8 3.2Mb 10ms DropTail
$ns duplex-link $n7 $n8 1.6Mb 10ms DropTail
#Gateway
#Change bandwidth value
$ns duplex-link $n8 $n9 3Mb 10ms DropTail
#Receivers
$ns duplex-link $n9 $n10 1Mb 10ms DropTail
$ns duplex-link $n9 $n11 1Mb 10ms DropTail
$ns duplex-link $n9 $n12 1Mb 10ms DropTail
$ns duplex-link $n9 $n13 1Mb 10ms DropTail
$ns duplex-link $n9 $n14 1Mb 10ms DropTail
$ns duplex-link $n9 $n15 1Mb 10ms DropTail

#Create Orientation for nam
$ns duplex-link-op $n0 $n6 orient right-down
$ns duplex-link-op $n1 $n6 orient right-down
$ns duplex-link-op $n4 $n7 orient right-down
$ns duplex-link-op $n6 $n8 orient right-down
$ns duplex-link-op $n9 $n13 orient right-down
$ns duplex-link-op $n9 $n14 orient right-down
$ns duplex-link-op $n9 $n15 orient right-down
$ns duplex-link-op $n2 $n6 orient right-up
$ns duplex-link-op $n3 $n6 orient right-up
$ns duplex-link-op $n5 $n7 orient right-up
$ns duplex-link-op $n7 $n8 orient right-up
$ns duplex-link-op $n9 $n10 orient right-up
$ns duplex-link-op $n9 $n11 orient right-up
$ns duplex-link-op $n9 $n12 orient right-up
$ns duplex-link-op $n8 $n9 orient right

#Create two UDP agents and attach them to nodes n4 and n5
set udp0 [new Agent/UDP]
set udp1 [new Agent/UDP]
$udp0 set class_ 1
$udp1 set class_ 1
$ns attach-agent $n4 $udp0
$ns attach-agent $n5 $udp1

# Create two CBR traffic sources and attach them to udp0 and udp1
set cbr0 [new Application/Traffic/CBR]
set cbr1 [new Application/Traffic/CBR]

#CHANGE THESE VALUES############################################
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.005
################################################################

$cbr0 attach-agent $udp0
$cbr1 attach-agent $udp1

#Create four TCP agents and attach them to nodes n0-n3
set tcp0 [new Agent/TCP/Reno]
set tcp1 [new Agent/TCP/Reno]
set tcp2 [new Agent/TCP/Reno]
set tcp3 [new Agent/TCP/Reno]
$tcp0 set window_ 20
$tcp1 set window_ 20
$tcp2 set window_ 20
$tcp3 set window_ 20
$ns attach-agent $n0 $tcp0
$ns attach-agent $n1 $tcp1
$ns attach-agent $n2 $tcp2
$ns attach-agent $n3 $tcp3
$tcp0 set packetSize_ 500
$tcp1 set packetSize_ 500
$tcp2 set packetSize_ 500
$tcp3 set packetSize_ 500
$tcp0 set fid_ 0
$tcp1 set fid_ 0
$tcp2 set fid_ 0
$tcp3 set fid_ 0


#Create a Null agents (traffic sinks) and attach them to receivers
set null0 [new Agent/TCPSink]
set null1 [new Agent/TCPSink]
set null2 [new Agent/TCPSink]
set null3 [new Agent/TCPSink]
set null4 [new Agent/Null]
set null5 [new Agent/Null]

$ns attach-agent $n10 $null0
$ns attach-agent $n11 $null1
$ns attach-agent $n12 $null2
$ns attach-agent $n13 $null3
$ns attach-agent $n14 $null4
$ns attach-agent $n15 $null5

#Connect the traffic agents with the traffic sinks
$ns connect $tcp0 $null0
$ns connect $tcp1 $null1
$ns connect $tcp2 $null2
$ns connect $tcp3 $null3
$ns connect $udp0 $null4  
$ns connect $udp1 $null5

#Create FTP applications and attach them to the agents
set ftp0 [new Application/FTP]
set ftp1 [new Application/FTP]
set ftp2 [new Application/FTP]
set ftp3 [new Application/FTP]

$ftp0 attach-agent $tcp0
$ftp1 attach-agent $tcp1
$ftp2 attach-agent $tcp2
$ftp3 attach-agent $tcp3

#Schedule events for the CBR agents
$ns at 1.0 "$cbr0 start"
$ns at 1.0 "$cbr1 start"
$ns at 4.5 "$cbr1 stop"
$ns at 4.5 "$cbr0 stop"
#Schedule events for the FTP agents
$ns at 1.0 "$ftp0 start"
$ns at 1.0 "$ftp1 start"
$ns at 1.0 "$ftp2 start"
$ns at 1.0 "$ftp3 start"
$ns at 4.5 "$ftp0 stop"
$ns at 4.5 "$ftp1 stop"
$ns at 4.5 "$ftp2 stop"
$ns at 4.5 "$ftp3 stop"
#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Run the simulation
$ns run

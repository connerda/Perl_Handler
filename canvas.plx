#!C:/Perl64/bin/perl

#this code is designed to take an input file
#that is properly spaced and put the information
#into a graphical output to be more readable
#
#Daniel Conner 7/31/2014
#Westinghouse
use Tkx;

#variable that will be changed by button presses)

#min and max
my $min = 0;
my $max = 0;
#Length/Width
my $LW = 0;
#depth
my $DP = 0;
#current depth used to go back and forth through the information
my $DPC=0;
my $count=0;
#location of a1
my $a1=0;
my $rowsNL = 0;
#global numbers to be used as arguments essentially
#I did this when I didn't quite understand passing arguments
#and kept it because it flows pretty well anyway

#to pass to visuals
my $globalNum=0;
#to pass to colorChoice
my $globalNum2=0;
#array of the alphabet to use to create a smaller array later
my @alphabet = ("A".."Z");
#the shortened alphabet
my @letterUsed = ();
#place to dump the letters as they come in, then we scan through it later
my @letterDump = ();
#global variable for what we will pull from line 1
my $title = "";

#to scan through the file to get all the information 
#we have two input loops. The first scan through is
#to understand the input and if we skipped any letters
open(Input, "Data.txt");
while(<Input>)
{
	my $line = $_;
	chomp($line);
	my @inits = split(' ',$line);
	#var for number of length and width
	$LW = @inits[0];
	#var for depth(num of arrays)
	$DP = @inits[1];
	#where A1 is (0 is top left, 1 is top right)
	$a1= @inits[2];
	#rows are numbers or letters (0 is numbers, 1 is letters)
	if(@inits[3] eq 'N'||@inits[3] eq 'n')
	{ $rowsNL = 0;}
	if(@inits[3] eq 'L'||@inits[3] eq 'l')
	{ $rowsNL = 1;}
	#title to display on the screen
	for ($i=4;$i<(scalar @inits);$i++)
	{
		$title = $title." ".@inits[$i];
	}
	my @lineArray;
	while(<Input>)
	{
		my $line = $_;
		chomp($line);
		@lineArray = split(' ',$line);
		if($rowsNL)
		{
			push (@letterDump, @lineArray[0]);
		}
		else
		{
			push (@letterDump, @lineArray[1]);
		}
	}
	#organize/thin down the letters
	foreach $i(@alphabet)
	{
		$tempValue=0;
		foreach $k(@letterDump)
		{
			if($i eq $k)
			{
				$tempValue = 1;
			}
		}
		if($tempValue == 1)
		{
			push(@letterUsed, "$i");
		}
	}
}

open(Input, "Data.txt");
while(<Input>)
{
	#first line tells us important info
	my($line) = $_;
	#drops enter at end of the line
	chomp($line);

	#the 3D Matrix
	my $fullMatrix;
	#
	for $a (0..($DP-1))
	{
		for $b(0..($LW-1))
		{
			for $c(0..($LW-1))
			{
				#the empty matrix that will be the dummy for everything else
				$fullMatrix[$a][$b][$c] = undef;
			}
		}
	}
	#temp varaibles to use in the next loop
	$row = 1;
	$col = 1;

	my @tempArray;
	my @lineArray;
	#second loop for all the actual data
	while(<Input>)
	{
		#store the first line
		my($line) = $_;
		#drops enter at end of the line
		chomp($line);
		#splits line for each space	
		@lineArray = split(' ',$line);
		#the following block of code is used to determine which
		#row and column the line is for
		$rowUsed=0;
		$colUsed=0;
		#row information (letter or number and in scope?)
		$tempCounter=0;
		foreach $i(@letterUsed)
		{
			if($i eq @lineArray[0])
			{
				$row = $tempCounter;
				$rowUsed=1;
			}
			$tempCounter=$tempCounter+1;
		}
		if($rowUsed==0)
		{
			$row=@lineArray[0]-1;
			if($row<$LW)
			{
				$rowUsed=1;
			}
		}
		#column information (letter or number and in scope?)
		$tempCounter=0;
		foreach $i(@letterUsed)
		{
			if($i eq @lineArray[1])
			{
				$col = $tempCounter;
				$colUsed=1;
			}
			$tempCounter=$tempCounter+1;
		}
		if($colUsed==0)
		{
			$col=@lineArray[1]-1;
			if($col<$LW)
			{
				$colUsed=1;
			}
		}
		#if the data is within our scope, add it to the 3d matrix and
		#use it in the max/min calculation
		#also we are going to quickly check if we need to flip the matrix or not
		#which is true if A1 is in the top right
		if($a1)
		{
			$tempNum = $LW;
			if(!$rowsNL)
			{
				$tempNum = scalar @letterUsed;
			}
			$subNum = 1;
			if($tempNum<$LW)
			{
				$subNum = $subNum+($LW-$tempNum);
			}
			$col = $LW-$col-$subNum;
		}
		if($rowUsed && $colUsed)
		{
			#0 and 1 are the locations
			for ($i=2; $i<$DP+2; $i++)
			{
				$temp = $lineArray[$i];
				if($temp != 0)
				{
					$temp = int($temp + $temp/abs($temp*2));
				}	
				#check minimum and maximum
				if($temp>$max)
				{
					$max=$temp;
				}
				elsif($temp<$min)
				{
					$min=$temp;
				}
				$k = $i-2;
				$fullMatrix[$k][$row][$col] = "$temp";
			}
		}
	}
}
close(Input);
#GUI Stuff
#initializing some variables
my $rectSize = 50;
my $titleBuff = $rectSize/2+30;#buffer on the sides
my $height = ($LW+4)*$rectSize+10;#to allow for header and space, added 10 to stop button overlap on information
my $width = $height+$rectSize; #to allow for buttons and other info on bottom
if($height<$titleBuff+260)#make sure the color scale is fully on the screen
{$height = $titleBuff+260}
#set up color range
my $diff=($max-$min);
my $rangeSize = $diff/8;

#start of graphics code
Tkx::wm_title(".", "Gui");
my $mw = Tkx::widget->new(".");
#creates the canvas that is used for all the data/rectangles
#only thing not on the canvas is the buttons
#that happened because canvas button documentation wasn't easy to track down
#and i already had buttons not on the canvas from trial 1
my $canvas = $mw->new_tk__canvas(-width => $width,-height => $height);
Tkx::grid_columnconfigure( ".", 0, -weight => 1); 
Tkx::grid_rowconfigure(".", 0, -weight => 1);

#color array
#lowest is blue, highest red
##FFEA00
#
my @colorArray =("purple","blue","darkturquoise","palegreen","yellow2","orange","red", "darkred");
my @colorLimit=();
#for showing the colors on the screen
$tempNum =0;
foreach (@colorArray)
{
	#this prints the color array and associated ranges 
	$canvas->create_rectangle(($LW+2)*$rectSize,($tempNum*30)+$titleBuff,($LW+2)*$rectSize+30,($tempNum*30)+$titleBuff+30, -fill=> $colorArray[7-$tempNum]);
	$temp = $max-($rangeSize*$tempNum);
	$temp2 = $temp-$rangeSize;
	$temp3 = int($temp2 + $temp2/abs($temp2*2));
	$temp4 = int($temp + $temp/abs($temp*2));
	
	$canvas->create_text(($LW+2)*$rectSize+3*$rectSize/2,($tempNum*30)+$titleBuff+$rectSize/4,-text=>"$temp3 ... $temp4");
	$tempNum++;
	push (@colorLimit, $temp4);
}
#calls the headers and visuals for initial setup
headers();
visuals();
#bind the arrow keys to what the left and right buttons do
$mw->g_bind('<KeyPress-Left>', sub{
		$globalNum=-1;
		visuals();
	});
$mw->g_bind('<KeyPress-Right>', sub{
		$globalNum=1;
		visuals();
	});

#all that is below is the subs and the main loop declaration

#intial setup of the headers as well as the buttons
sub headers
{
	#title
	$canvas->create_text(3*$rectSize/2+($rectSize*($LW))/2,$rectSize/4+15,-text=>"$title", -font=>"Arial 18");
	#for loop for header labels
	#it is complex to account for headers being switched based on user choice
	#this needs to account for A1 being in the top left or right corner
	#as well as whether the row and column headers are numbers or letters
	$sizeLett = scalar @letterUsed;
	#print @letterUsed;
	for $i(1 .. $LW)
	{
		#A1(0 is top left, 1 is top right) $a1
		#rows (0 is numbers, 1 is letters) $rowsNL
		$ouput = " ";
		$output2 = " ";
		if($a1)
		{
			#A1 right, rows letters
			if($rowsNL)
			{
				$output = $LW-$i+1;
				$output2 = @letterUsed[$i-1];
			}
			#A1 right, rows numbers
			else
			{
				$j=($sizeLett-1)-($i-1);
				if($j==-1)
				{	
					#set header to blank
					$output = " ";
				}
				else
				{
					$output = @letterUsed[$j];
				}
				$output2 = $i;
			}
			
		}
		else
		{
			#A1 left, rows Letters
			if($rowsNL)
			{
				$output = $i;
				$output2 = @letterUsed[$i-1];
			}
			#A1 left, rows numbers
			else
			{
				$output = @letterUsed[$i-1];
				$output2 = $i;
			}
		}
		$temp = $rectSize*$i;
		#top header
		$canvas->create_rectangle($temp+($rectSize/2), $rectSize/2+30, $temp+3*$rectSize/2,3*$rectSize/2+30);
		$canvas->create_text(int($temp+$rectSize), int($rectSize)+30, -text =>"$output");
		#side header
		$canvas->create_rectangle($rectSize/2,$temp+($rectSize/2)+30,3*$rectSize/2,$temp+3*$rectSize/2+30);
		$canvas->create_text(int($rectSize), int($temp+$rectSize+30), -text => "$output2");
	}
	$canvas->g_grid(-column => 0, -row => 0, -columnspan=>($LW+2), -rowspan=>($LW+2), -sticky=>"nwes");
	#left arrow
	$left = $mw->new_ttk__button(-text=> "<", -command => 
	sub{
		$globalNum=-1;
		visuals();
	});
	$left->g_grid(-column=>0, -row=>3,-sticky=>"nw", -padx=>40);
	#right arrow
	$right = $mw->new_ttk__button(-text=> ">", -command =>
	sub{
		$globalNum=1;
		visuals();
	});
	$right->g_grid(-column=>0, -row=>2, -sticky=>"sw", -padx=>40);
	#buffer to the bottom of the grid
	$buffer = $mw->new_ttk__label(-text=>"  ");
	$buffer->g_grid(-column=>0, -row=>4, -padx=>40, -pady=>4);
	#signature of the programmer of this script. I was told it would be a good idea to put my name on it
	$sig = $mw->new_ttk__label(-text=>"Programmer: Daniel Conner");
	$sig->g_grid(-column=>1, -row=>4, -sticky=>"s", -padx=>5, -pady=>5);
}

#this is to set up all the visuals, runs when the user clicks an arrow
#also changes the label that is off the canvas to represent what level
#we are currently vieiwing
sub visuals
{
	#background color so to speak. what shows up on empty blocks/headers
	$color2 = "gray95";
	#global variable we set to what we are adding to this (-1 or 1)
	$tempAdd = $globalNum;
	#adjust the current depth
	$DPC =$DPC+$tempAdd;
	#print "$tempAdd";
	if($DPC<0)
	{
		$DPC=0;
	}
	elsif($DPC>$DP-1)
	{
		$DPC=$DP-1;
	}
	#no need to remake shapes if someone tries to go past what exists
	else
	{	
		$output="";
		for $i(1..$LW)#col
		{
			for $b(1..$LW)#row
			{
				$tempX = ($i*$rectSize);
				$tempY = ($b*$rectSize);
				$stringName = $i."a".$b."a".$DPC."a".$count;
				#remember: we initially declared the full matrix as "undef"
				#all throughout, so any empty slots should still be undef
				#this checks to make sure there is something besides undef there
				#we cannot do FM[][][] == undef because it views 0 as undef
				#and we have multiple 0s
				if(defined $fullMatrix[$DPC][($b-1)][($i-1)])
				{
					$output = $fullMatrix[$DPC][($b-1)][($i-1)];
					#issue here with the max number not having a color/getting overwritten
					$globalNum2=$output;
					colorChoice();
					#global num2 is set by this function, then by colorchoice, and then 
					#we use it again here to determine the color.
					#it will always be in the range
					$color = @colorArray[$globalNum2];
					$canvas->create_rectangle($tempX+($rectSize/2),$tempY+($rectSize/2)+30,$tempX+(3*$rectSize/2),$tempY+(3*$rectSize/2)+30,-fill=>$color, -width=>5);
					$canvas->create_text(int($tempX+$rectSize), int($tempY+$rectSize)+30, -text =>"$output", -font=>"15");
				}
				else
				{
					$canvas->create_rectangle($tempX+($rectSize/2),$tempY+($rectSize/2)+30,$tempX+(3*$rectSize/2),$tempY+(3*$rectSize/2)+30);
				}
			}
		}	
	}
	#the label to tell up the current depth
	$temp2 = $DPC+1;
	$label = $mw->new_ttk__label(-text=>"Layer: $temp2", -font=>"Arial 10");
	$label->g_grid(-column=>0, -row=>1, -sticky=>"sw", -padx=>40);
}

#function to choose the color for us
sub colorChoice
{
	$retInt=7;
	for ($a=0;$a<8;$a++)
	{
		if($globalNum2<@colorLimit[7-$a])
		{
			$retInt=$a;
			last;
		}
	}
	# $retDub = (($globalNum2-$min)/$rangeSize);
	# $retInt =  int($retDub + 0.5); #rounding positive numbers (if negative, its going to 0 anyway)
	# if($retInt>7)
	# {
		# $retInt=7;
	# }
	# elsif($retInt<0)
	# {
		# $retInt=0;
	# }
	$globalNum2 = $retInt;
}
#main loop call
Tkx::MainLoop();

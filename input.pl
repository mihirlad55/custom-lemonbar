use strict;
use warnings;
use diagnostics;
use feature 'say';
use IO::Socket::UNIX;


my $ARROW_LEFT_SOLID = "";
my $ARROW_RIGHT_SOLID = "";
my $ARROW_LEFT = "";
my $ARROW_RIGHT = "";
my $BAR = "█";

my $SYM_BAT_CHR = " ";
my $SYM_BAT_FULL = "l";
my $SYM_BAT_75 = " ";
my $SYM_BAT_50 = " ";
my $SYM_BAT_25 = " ";
my $SYM_BAT_0 = " ";

my $SYM_WIFI = " ";

my $SYM_CLOCK = " ";

my $SYM_CALENDAR = " ";

my $SYM_VOLUME_UP = " ";
my $SYM_VOLUME_DOWN = " ";
my $SYM_VOLUME_OFF = " ";

my @SYM_BRIGHTNESS = (
    "",
    "",
    "");

my $SYM_BRIGHTNESS_AUTO = "";

my @COLOR_STRENGTH = ( 
    "#0074D9",
    "#2ECC40", 
    "#FFDC00", 
    "#FF4136");

my @COLOR_POWER = ( 
    "#0074D9", 
    "#2ECC40", 
    "#FFB86C", 
    "#FFDC00", 
    "#FF4136");

my @COLOR_PRIMARY = ( 
    "#2B2D42", 
    "#1A1D21", 
    "#2B2D42", 
    "#1A1D21", 
    "#2B2D42", 
    "#1A1D21",
    "#1A1D21");

my @COLOR_SECONDARY = ( 
    "#FEFEFE", 
    "#FEFEFE", 
    "#FEFEFE", 
    "#FEFEFE", 
    "#FEFEFE", 
    "#FEFEFE",
    "#FEFEFE");


$| = 1; # REMOVE BUFFERING IMPORTANT
STDERR->autoflush;
STDOUT->autoflush;

#chomp(my $path = qx(i3 --get-socketpath));
#my $sock = IO::Socket::UNIX->new(Peer => $path);

#sub format_ipc_command {
#    my ($msg) = @_;
#    my $len;

#    {use bytes; $len = length($msg); }
#    
#    return "i3-ipc" . pack("LL", $len, 0) . $msg;
#}
#
#print 'sending';
##$sock->write(format_ipc_command("1"));
#print 'sent';
#$sock->write("i3-ipc" . pack("LL", 0, 1));
#$sock->autoflush(1);
#
#print 'entering loop';
#    while (my $line = <$sock>) {

#        print "waiting";
#        sleep 1;
#        if ($line){
#            chomp($line);
#            print("Recv: '" . $line . "'\n");
#        }
#    }

#print 'passeed';

while (1) {
    my $time = lc `date +"%I:%M%p"`;
    chomp $time; # Remove new line character

    my $date = `date +"%a %b %d"`;
    chomp $date; # Remove new line character

    my $bat = `cat /sys/class/power_supply/BAT0/charge_now` / `cat /sys/class/power_supply/BAT0/charge_full` * 100;
    $bat = int $bat;

    my $CHR = `cat /sys/class/power_supply/AC/online`;

    my $colorBat;

    if ($CHR == 1) {
        $bat = "$SYM_BAT_CHR $bat%";
        $colorBat = $COLOR_POWER[0];
    }
    else {
        if ( $bat == 100 ) {
            $bat = "$SYM_BAT_FULL $bat%";
            $colorBat = $COLOR_POWER[0];
        } elsif ( $bat > 75 ) {
            $bat = "$SYM_BAT_75 $bat%";
            $colorBat = $COLOR_POWER[1];
        } elsif ( $bat > 50 ) {
            $bat = "$SYM_BAT_50 $bat%";
            $colorBat = $COLOR_POWER[2];
        } elsif ( $bat > 10 ) {
            $bat = "$SYM_BAT_25 $bat%";
            $colorBat = $COLOR_POWER[3];
        } else {
            $bat = "$SYM_BAT_0 $bat%";
            $colorBat = $COLOR_POWER[4];
        }
    }
    
    my $ipInterface = `ip addr show | awk '/inet.*brd/{print \$NF}'`;
    chomp $ipInterface; # Remove null character
    my $colorIP;
    my $ip = `ip addr show | grep -o 'inet.*brd' | cut -d ' ' -f 2 | cut -d '/' -f 1`;
    chomp $ip; # Remove new line character

    my $ipText = "";

    if ($ipInterface ne "") {
        my $ipQuality = `iw $ipInterface station dump | awk '/signal avg:/{print \$3; exit;}'`;

        if ( $ipQuality < -70 ) {
            $colorIP = $COLOR_STRENGTH[3];
        } elsif ( $ipQuality < -60 ) {
            $colorIP = $COLOR_STRENGTH[2];
        } elsif ( $ipQuality < -50 ) {
            $colorIP = $COLOR_STRENGTH[1];
        } else {
            $colorIP = $COLOR_STRENGTH[0];
        }

        $ipText = "$ipInterface:  $ip";
    } else {
        $colorIP = $COLOR_STRENGTH[3];
    }
        

    my $volume = `amixer get 'Master' | awk '/\\[(on)|(off)\\]/{print \$3; exit}' | tr -d '[]%\n'`;

    if ( $volume > 25 ) {
        $volume = "$SYM_VOLUME_UP  $volume%";
    } elsif ( $volume > 0 ) {
        $volume = "$SYM_VOLUME_UP  $volume%";
    } else {
        $volume = "$SYM_VOLUME_UP  $volume%";
    }

    my $activeWindowTitle = `xprop -id \$(xprop -root 32x '\t\$0' _NET_ACTIVE_WINDOW | cut -f 2) _NET_WM_NAME | sed 's/^_NET_WM_NAME(UTF8_STRING) = //g' | tr -d '""\n'`;

    my $brightness = int `cat /sys/class/backlight/intel_backlight/brightness` / `cat /sys/class/backlight/intel_backlight/max_brightness` * 100;

    my $brightnessText;
    if ($brightness == 100) {
        $brightnessText = $SYM_BRIGHTNESS[2];
    } elsif ($brightness >= 50) {
        $brightnessText = $SYM_BRIGHTNESS[1];
    } else {
        $brightnessText = $SYM_BRIGHTNESS[0];
    }
    $brightnessText .= "  $brightness%";

    my $blockTime = "%{F$COLOR_PRIMARY[0]}$ARROW_LEFT_SOLID%{B$COLOR_PRIMARY[0]}%{F$COLOR_SECONDARY[0]}  $SYM_CLOCK  $time ";

    my $blockDate = "%{F$COLOR_PRIMARY[1]}$ARROW_LEFT_SOLID%{B$COLOR_PRIMARY[1]}%{F$COLOR_SECONDARY[1]}   $SYM_CALENDAR   $date";

    my $blockBat = "%{F$COLOR_PRIMARY[2]}$ARROW_LEFT_SOLID%{B$COLOR_PRIMARY[2]}%{F$colorBat}   $bat";

    my $blockIp = "%{F$COLOR_PRIMARY[3]}$ARROW_LEFT_SOLID%{B$COLOR_PRIMARY[3]}%{F$colorIP}  $SYM_WIFI  %{F$COLOR_SECONDARY[3]}$ipText" ;

    my $blockVolume = "%{F$COLOR_PRIMARY[4]}$ARROW_LEFT_SOLID%{B$COLOR_PRIMARY[4]}%{F$COLOR_SECONDARY[4]}  $volume";
    
    my $blockBrightness = "%{F$COLOR_PRIMARY[5]}$ARROW_LEFT_SOLID%{B$COLOR_PRIMARY[5]}%{F$COLOR_SECONDARY[5]}  $brightnessText";

    my $blockWindowTitle = "%{F$COLOR_PRIMARY[6]}$ARROW_LEFT_SOLID%{B$COLOR_PRIMARY[6]}%{F$COLOR_SECONDARY[6]} $activeWindowTitle";

    my $blockWorkspaces = "%";

    say "%{Sl}$blockWindowTitle%{r} $blockBrightness $blockVolume$blockIp$blockBat$blockDate $blockTime %{B-}";

    sleep 1;
}

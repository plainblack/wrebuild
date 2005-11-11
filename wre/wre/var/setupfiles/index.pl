#!/data/wre/prereqs/perl/bin/perl

our ($webguiRoot, $configFile);

BEGIN {
        $configFile = "__sitename__.conf";
        $webguiRoot = "__webgui-home__";
        unshift (@INC, $webguiRoot."/lib");
}

#-----------------DO NOT MODIFY BELOW THIS LINE--------------------

use CGI::Carp qw(fatalsToBrowser);
use strict;
use WebGUI;

print WebGUI::page($webguiRoot,$configFile);


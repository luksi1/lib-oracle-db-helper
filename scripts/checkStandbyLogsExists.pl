#!/usr/bin/perl

use lib qw(/opt/oracle/scripts/classes/lib);
use OracleHelper::Info;
use Getopt::Long;

GetOptions("sid:s"=>\$sid);

$oracle = new Info();
$oracle->setEnv($sid);
$result = $oracle->checkIfStandbyLogsExist();
print $result . "\n";

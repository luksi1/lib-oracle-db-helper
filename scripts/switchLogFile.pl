#!/usr/bin/perl

use lib qw(/opt/oracle/scripts/classes/lib);
use OracleHelper::Base;
use Getopt::Long;

GetOptions("sid:s"=>\$sid,
		"all"=>\$all);

if ($all) {
	&switchLogFileAll();
} elsif ($sid) {
	&switchLogFileDb();
} else {
	print "You have to indicate a parameter\n";
	exit;
};
	

sub switchLogFileAll {
	my $oracle = new Base();
	@databases = $oracle->oracleDatabases();
	foreach $db(@databases) {
		$oracle->setEnv($db);
		@role = $oracle->databaseRole();
		foreach $dbRole(@role) {
			next if $dbRole !~ /PRIMARY/;
			$oracle->switchLogFile();
		};
	};
}

sub switchLogFileDb {
	my $oracle = new OracleInfo();
	$oracle->setEnv($sid);
	@role = $oracle->databaseRole();
	foreach $dbRole(@role) {
		exit if $dbRole !~ /PRIMARY/;
		$oracle->switchLogFile();
	};
}

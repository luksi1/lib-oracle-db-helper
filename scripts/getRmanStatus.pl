#!/usr/bin/perl

use lib qw(/opt/oracle/scripts/classes/lib);
use OracleHelper::Database;
use Getopt::Long;

GetOptions("sid:s"=>\$sid,
                "all"=>\$all);

if (!defined $all && !defined $sid) {
        print "You must indicate a parameter";
        exit 1;
} elsif ($all && $sid) {
        print "You can only set one parameter -sid or -all";
        exit 1;
};

if ($all) {
        &rmanStatusAll();
} elsif ($sid) {
        &rmanStatusDb();
};

sub rmanStatusAll
{
        my $oracle = new Database();
        @databases = $oracle->oracleDatabases();
        foreach $db(@databases) {
                $oracle->setEnv($db);
		@role = $oracle->databaseRole();
                foreach $dbRole(@role) {
                        next if $dbRole !~ /PRIMARY/;
			@result = $oracle->rmanStatus();
			if (scalar(@result)==0) {
				exit 0;
			} else {
				print "scalar(@result) errors found";
				exit 1;
			};
                };
        };
}

sub rmanStatusDb
{
	my $oracle = new Database();
	$oracle->setEnv($sid);
	@role = $oracle->databaseRole();
	foreach $dbRole(@role) {
		next if $dbRole !~ /PRIMARY/;
                @result = $oracle->rmanStatus();
		$size = scalar @result;
                if ($size == 0) {
                        exit 0;
                } elsif ($size >= 1) {
                        print "$size errors found";
                        exit 1;
                };
	};
}

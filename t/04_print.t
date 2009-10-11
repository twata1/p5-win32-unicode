use strict;
use warnings;
use Test::More tests => 5;
use Test::Exception;
use Test::Output;

my $wuct = 'Win32::Unicode::Console::Tie';
tie *{Test::More->builder->output}, $wuct;
tie *{Test::More->builder->failure_output}, $wuct;
tie *{Test::More->builder->todo_output}, $wuct;

unless ($^O eq 'MSWin32') {
	plan skip_all => 'MSWin32 Only';
	exit;
}

use Win32::Unicode;
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $str = " I \x{2665} Perl";

TODO: {
	local $TODO = 'ToDo';
	stdout_is { printW($str) }  $str;
	stdout_is { printfW("[%s]", $str) } "[$str]" ;
	stdout_is { sayW($str) } "$str\n";
};

ok warnW($str), "warnW";
dies_ok { dieW($str) } "dieW";

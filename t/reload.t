# reload -*-perl-*-
use Test;
BEGIN { plan tests => 8 }

use Module::Reload;
ok 1;

# $Module::Reload::Debug = 2;

sub rewrite {
    my ($x) = @_;
    open(F,">testin");
    print F '$main::test = '."$x\n";
    close F;

    # make sure whatever *FS cache is flushed
    while (1) {
	open(F,"testin");
	my $l = <F>;
	last if $l =~ /$x/;
    } continue { close F; }

    require "testin";
}

rewrite(1);
 
Module::Reload->check;

ok $test;
$test = 2;
 
Module::Reload->check;
 
ok $test, 2;
 
sleep 1;  #modification times are in seconds...get a new one
rewrite(3);
 
ok $test, 2;

Module::Reload->check;

ok $test, 3;

sleep 1;  #modification times are in seconds...get a new one
rewrite(4);

my $called = 0;
Module::Reload->check(sub {
    my $name = shift;
    ok $name, 'testin';
	$called = 1;
});

ok $called, 1;
ok $test, 4;

unlink("testin");

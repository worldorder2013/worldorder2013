#!/usr/bin/env perl
# Application by Richmond Kerville Magallon

use Tk 800.000;
use Tk::HList;

use strict;
## global variables
my %ERRORS;
my %WARNINGS;
my %MSG;
my $filename;

# GUI Tk starts here
my $top = MainWindow->new();
$top->title("RK*MaG Log File Browser");
my $menu = $top->Menu;

$top->configure(-width => 300); 


## Menu GUI
$top->configure(-menu => my $menubar = $top->Menu); 
my $file = $menubar->cascade(-label => '~File', -tearoff=>0); 
my $edit = $menubar->cascade(-label => '~Edit'); 
my $help = $menubar->cascade(-label => '~Help'); 


my $newfile = $file->cascade(
	-label => 'Choose Tool',
	-underline => 0,
	-tearoff => 0
);
$file->separator;
$file->command(
	-label => 'Open',
	-underline => 0,
	-command => \&open_file
);

my $tool = "innovus";

my $tools_ = [['Innovus', "innovus"], ['ICC2', "icc2"], ['Tempus', "tempus"]];

foreach (@$tools_){
	$newfile->radiobutton(
        	-label => $_->[0],
        	-variable => \$tool,
        	-value =>  $_->[1]
	);
}
#$newfile->radiobutton(
#	-label => "Innovus",
#	-variable => "$tool",
#	-value => "innovus"
#);
#$newfile->radiobutton(
#	-label => "ICC2",
#	-variable => "$tool",
#	-value => "icc2"
#);

$help->command(-label => 'Log Parser v1.0');
$help->command(-label => 'rk*MaG');
my $fr = $top->Frame(-width => 1000, -height => 2000);
my $l = $fr->Label(-text => 'Log Browser', -anchor => 'n', -relief => 'groove',-width => 10, -height => '3');
my $l_bottom = $top->Label(-text => "No log file selected", -anchor => 'n', -relief => 'groove', -height => '3');


my $hlist = $top->Scrolled('HList', -selectmode => 'extended', -indent => 10, -drawbranch => 1); 
## main Error header
$hlist->add("Errors", -text => "Errors"); 
## main Warning header
$hlist->add("Warnings", -text => "Warnings"); 
$hlist->configure(-width=>18);
$hlist->configure(-height=>30);
$hlist->configure(-command=>\&cb_populate_warning_error_textfield);

## text Gui
my $text = $fr->Text(-background => 'white');
$text->configure(-height => 40);
$text->configure(-width => 150);
my $btn1 = $fr->Button(-text => 'Exit', -anchor=>'n', -command => sub {exit});

## Geometry management
#$l->pack(-side => "top");
$hlist->pack(-side=>'left', -anchor=>'n');
#$btn1->pack(-side=>"top", -expand=>1);
$text->pack(-side=>'right', -anchor=>'e', -fill=> 'x', -expand => 1);
$fr->pack(-expand => 1, -side=>'top', -anchor=>'w', -fill=>'x');
$l_bottom->pack(-side => "bottom", -fill=>'x');
MainLoop();

sub open_file {
	our $h=$top->getOpenFile();
	if ($h eq ""){
	  return;
	}
	if ($tool eq "innovus"){
		&parse_error_warn_innovus($h);
	}
	&populate_hlist_tree;
	my $file_mod_time = localtime((stat($h))[9]);
	$l_bottom->configure(-text=>"$h $file_mod_time" );
}

sub parse_error_warn_innovus {
$filename = shift @_;
$filename = '/lsc/scratch/logic_ip/apollo/rmagallo/earth/logs.log29';
open(fh, "<$filename");
# or die "Couldn't open file $filename: $!";
while (<fh>) {
	chomp $_;
	if (/\*\*ERROR: \((\S+)\)/){
		push (@{$MSG{Errors}{$1}}, $_);
	}
	if (/\*\*WARN: \((\S+)\)/){
		push (@{$MSG{Warnings}{$1}}, $_);
	}
}
close fh;

}

sub populate_hlist_tree {
	my @text;
	my $num_msg;
	foreach (sort keys %{$MSG{Errors}}) {
		$num_msg = scalar( @{$MSG{Errors}{$_}});
		$hlist->add("Errors.$_", -text => "$_ ($num_msg)"); 
	} 
	foreach (sort keys %{$MSG{Warnings}}) {
		$num_msg = scalar( @{$MSG{Warnings}{$_}});
		$hlist->add("Warnings.$_", -text => "$_ ($num_msg)"); 
	} 
}

sub print_warnings {
foreach (keys %WARNINGS) {
	print "@{$WARNINGS{$_}}\n";

}

}

sub cb_populate_warning_error_textfield {
	my ($widget , $mode) = @_;
	my ($msg_type, $msg_code) = split(/\./,$widget);
	$text->selectAll;
	$text->deleteSelected;
	if ( $msg_code eq ""){
		foreach (sort keys %{$MSG{$msg_type}}){
			$text->insert('end', "$_\n");
		}
		return;
	}
	foreach ( @{$MSG{$msg_type}{$msg_code}}){
		$text->insert('end', "$_\n");
	}
}

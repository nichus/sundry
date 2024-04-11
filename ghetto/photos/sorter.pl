#!/usr/bin/perl
#
use strict;
use warnings;
use Digest::SHA qw(sha512224_hex);

use Image::ExifTool;
use POSIX qw(strftime);
use File::Copy;
use File::Basename;
use File::Path qw(make_path);
use Time::Local qw(timelocal);

my @stat;
my $ArchiveDir = '/mnt/beast/picture/Pictures';
my $exifTool = new Image::ExifTool;
$exifTool->Options(DateFormat => '%s');

if (scalar(@ARGV) != 1) {
  print "Specify image filename on commandline\n";
  exit 1;
}

my $file    = $ARGV[0];
my $info    = $exifTool->ImageInfo($file);
my $ctime   = &sane_time(&find_time($info),$file);
my @time    = localtime($ctime);

my $folder  = strftime("%Y/%m/%Y-%m-%d",@time);
my $touch   = strftime("%Y-%m-%d %H:%M:%S",@time);
my $target  = "$ArchiveDir/$folder";

my $basename = basename($file);

#print "File:   $file\n";
#print "Folder: $folder\n";
#print "UNIX:   $ctime\n";
#print "Touch:  $touch\n";
#print "\n";
#
#print join "\n", keys %$info;

if (not -d $target) {
  print "Created directory for pictures: $target\n";
  make_path($target);
  #mkdir $target;
}

my $destination = "$target/$basename";
if (&same_file($file,$destination)) {
  print "Source and destination directories are the same, giving up before I hurt something\n";
  exit 1;
}

my $dsize=0;
if (-f $destination) {
  #  print "$destination exists";
  $dsize = -s $destination;
  if ($dsize != 0) {
    my $ohex = &digest($file);
    if ($ohex eq &digest($destination)) {
      printf " d -> %s -- removing locally\n", $destination;
      unlink $file;
    } else {
      printf " w !! %s != %s, rename required\n", $destination, $file;
      # print " -- files are different, '$file' needs a rename\n";
    }
  } else {
    printf " z -> %s\n", $destination;
    # print "$file -> $destination\n";
    copy($file, $destination);
    no warnings qw(uninitialized);
    utime undef, $ctime, $destination;
  }
} else {
  printf " c -> %s\n", $destination;
  # print "$file -> $destination\n";
  copy($file, $destination);
  no warnings qw(uninitialized);
  utime undef, $ctime, $destination;
}

sub same_file() {
  my ($source,$dest) = @_;
  my ($sdev,$sino,undef) = stat($source);
  my ($ddev,$dino,undef) = stat($dest);

  if ( $ddev and ($sdev == $ddev) and ($sino == $dino)) {
    return 1;
  }
  return 0;
}
sub find_time() {
  my ($info) = @_;
  my @times =qw(CreateDate DateTimeOriginal ModifyDate FileModifyDate FileAccessDate);

  foreach my $key (@times) {
    exists $info->{$key} and return $info->{$key};
  }
  return 0;
}
sub sane_time() {
  my ($ts,$file) = @_;
  my ($year,$month,$date,$hour,$min,$sec);

  # So far, this is the only insane time I've encountered, so if we a time that isn't it, just use it.
  if ($ts !~ /0000:00:00 00:00:00/) {
    return $ts;
  }

  $file =~ s/[a-zA-Z]//g; # Remove all letters from the filename (which is becoming our timestamp
  $file =~ s/^[^\d]+|[^\d]+$//g; # Remove all non digits from the end of the string

  if ($file =~ /(\d{4})\.?(\d{2})\.?(\d{2})/) {
    $year = $1;
    $month = $2;
    $date = $3;
    $file =~ s/\d{4}\.?\d{2}\.?\d{2}//;


    $month -= 1;    # Because perl
    $year  -= 1900; # Because perl
  }
  if ($file =~ /(\d{2})\.?(\d{2})\.?(\d{2})/) {
    $hour = $1;
    $min = $2;
    $sec = $3;
    $file =~ s/\d{2}\.?\d{2}\.?\d{2}//;
  }

  print "$file -> $ts -> $year/$month/$date $hour:$min:$sec\n";
  exit(1);

  return timelocal($sec,$min,$hour,$date,$month,$year,0,0,0);
}

sub digest() {
  my ($file) = @_;
  my $sha     = Digest::SHA->new(512224);
  $sha->addfile($file);
  return $sha->hexdigest();
}


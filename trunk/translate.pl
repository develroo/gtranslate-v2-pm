#!/usr/bin/perl

# *************************************************************************************
#
#
# translate.pl is a simple CLI utility to translate strings using the GTranslate API v2.
# The idea is that it takes a destination language and a series of strings, and returns
# the translated version of the strings. Really, though, it's a simple demo of the
# GTranslateV2.pm
#
# usage: ./translate.pl destLang str1 [str2 str3 str4...]
#
#
# *************************************************************************************





use warnings;
use strict;
use lib 'lib';
use GTranslateV2;
use Data::Dumper;


# configuration variable

my $apiKey = 'AIzaSyDqiJWqGKuk9ExcjmBH7X4gB6_COpK0t9s'; # GTranslate API v2 key. Change this to your own. Please and thank you.

# end configuration


my $destLang = $ARGV[0]; # the destination language code
my @stringsToTranslate = @ARGV[1..(@ARGV-1)]; # the array of strings to translate

for(my $i = @stringsToTranslate; $i > 0; $i--){
  if(!GTranslateV2::gtg($stringsToTranslate[$i])){
    delete $stringsToTranslate[$i];
  }
}


# print "\n==== translate us! (" . @stringsToTranslate . ")====\n";
# print join("\n", @stringsToTranslate);
# print "\n==== translate us! ====\n";

my $translator = GTranslateV2->new(key => $apiKey); # initialize the translator.

for (my $i = 0; $i < @stringsToTranslate; $i += 128){ # loop through the strings to get them all
  my $endI = (@stringsToTranslate - $i > 128) ? $i + 127 : @stringsToTranslate-1; # figure out how many 
  my @thisBatch = @stringsToTranslate[$i..$endI];
  my @translatedStrings = $translator->translate(source => '', target => $destLang, q => \@thisBatch); # run the translations
  if(my $err = $translator->{error}){ # error handling
    print qq~Translation Error (~ . $err->{code} . qq~): ~ . $err->{message} . qq~\n~;
    next;
  }
  for(my $j = 0; $j < @translatedStrings; $j++){ # loop through and print the translated pairs
    print $stringsToTranslate[$i + $j] . " -> " . $translatedStrings[$j]->{translatedText} . "\n";
  }
}

exit;
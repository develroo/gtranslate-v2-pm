# *************************************************************************************
#
#
# detect.pl is a simple CLI utility to detect language using the GTranslate API v2.
# The idea is that it takes detects the language of a series of strings, and returns
# the language codes version of the strings. Really, though, it's a simple demo of the
# GTranslateV2.pm
#
# usage: ./detect.pl str1 [str2 str3 str4...]
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


my @stringsToDetect = @ARGV; # the array of strings to translate

for(my $i = @stringsToDetect; $i > 0; $i--){
  if(!GTranslateV2::gtg($stringsToDetect[$i])){
    delete $stringsToDetect[$i];
  }
}

# print "\n==== translate us! (" . @stringsToTranslate . ")====\n";
# print join("\n", @stringsToTranslate);
# print "\n==== translate us! ====\n";

my $translator = GTranslateV2->new(key => $apiKey); # initialize the translator.


for (my $i = 0; $i < @stringsToDetect; $i += 128){ # loop through the strings to get them all
  my $endI = (@stringsToDetect - $i > 128) ? $i + 127 : @stringsToDetect-1; # figure out how many 
  my @thisBatch = @stringsToDetect[$i..$endI];
  my $response = $translator->detect(q => \@thisBatch); # run the translations
  if(my $err = $response->{error}){ # error handling
    print qq~Translation Error (~ . $err->{code} . qq~): ~ . $err->{message} . qq~\n~;
    next;
  }
  my $detections = $response->{data}->{detections}; # get the array of detections.
  print Dumper $detections;
  for(my $j = 0; $j < @{$detections}; $j++){ # loop through and print the detected languages
    my $detection = $detections->[$j]->[0]; # apparently, the big G may return more than one possibility. Haven't seen it, but this is a nested array.
    print $stringsToDetect[$i + $j] . " -> " . $detection->{language} . " (" . $detection->{confidence} . ")\n";
  }
}

exit;
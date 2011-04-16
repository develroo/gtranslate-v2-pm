#!/usr/bin/perl

# *************************************************************************************
#
#
# languages.pl is a simple CLI utility to list the languages available using the GTranslate API v2.
# The idea is that it takes an optional target language and returns
# listing of the supported languages. Really, though, it's a simple demo of the
# GTranslateV2.pm
#
# usage: ./languages.pl destLang?
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


my $translator = GTranslateV2->new( key => $apiKey ); # initialize the translator

my @languages = $translator->getLanguageEnum(target => $ARGV[0]); # get the enum

if(defined($translator->{error})){ # error handling. Gotta be graceful!
  warn "ERROR (code " . $translator->{error}->{code} . "): " . $translator->{error}->{message} . "\n";
  exit;
}

foreach my $lang (@languages){ # print out the enum
  if(GTranslateV2::gtg($lang->{name})){
    print $lang->{name} . " (" . $lang->{language} . ")";
  }else{
    print $lang->{language};
  }
  print "\n";
}

exit(0);
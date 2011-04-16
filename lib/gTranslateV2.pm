package GTranslateV2;


# *************************************************************************************
#
# GTranslateV2.pm is a Perl module to interact with the GTranslate API v2.
# NOTE: You can send up to 128 strings to any of the methods. Pass strings as an array REFERENCE.
#
# usage:
# use GTranslateV2;
# my $translator = GTranslateV2->new( # initialize the translator
#   key => [YOUR_API_KEY]
# );
# var $response = $translator->translate( # translate strings
#   target => 'de', # destination language code
#   q => [ # strings to translate. Notice that this is an array reference.
#     'Hello, world!',
#     'How are you today?'
#   ],
#   source => 'en', # [OPTIONAL] source language code
#   prettyprint => 0, # [OPTIONAL] boolean prettyprint argument
#   'format' => 'text' # [OPTIONAL] text|html specifies format of your source string(s)
# foreach my $translation (@{$response->{data}->{translations}}) {
#   print $translation . "\n"; # print out the translations
# }
#   
#
# *************************************************************************************


use version 0.77; our $VERSION = qv("v0.1_3");
our $debug = 0; # set to 1 for debugging mode, which will activate certain status messages, etc.


use warnings;
use strict;
use LWP::UserAgent; # We'll use this to talk to the GServers
use JSON; # We'll use this to process the JSON responses
if($debug){
  eval{
    use Data::Dumper;
  };
  if($@ ne ''){
    warn "Unable to include Data::Dumper!\n";
  }
}

use base 'Exporter';
our $EXPORT = qw~~; # stuff to export when we're done.


# basic configuration stuff
use constant BASE_URL => 'https://www.googleapis.com/language/translate/v2'; # base url for the api
use constant DEFAULT_TARGET_LANGUAGE => 'en'; # default destination language
use constant INSUFFICIENT_STRINGS_MESSAGE => qq~You didn\'t send anything to translate!~; # error message for if we don't have any strings to process
use constant TOO_MANY_QUERY_STRINGS_MESSAGE => qq~You may only send up to 128 strings to translate.~; # error message for if we have too many strings to process.
use constant DEFAULT_STRING_FORMAT => 'text'; # set the default text format to text. This can be overridden by sending the format argument to the methods
# end basic configuration stuff




sub new{ # initialize the translator
  my $class = shift;
  my %args = @_;
  my %self = (
    key => $args{key},
    ua => LWP::UserAgent->new() # initialize the useragent object for later use
  );
  $self{ua}->default_header('X-HTTP-Method-Override' => 'GET');
  return bless \%self;
}




# *************************************************************************************
#
# Usage:
# my @translations = $translator->translate( q => \@stringsToTranslate, target => $destLang, source => $srcLang, 'format' => $stringFormat );
#
# *************************************************************************************

sub translate{ # run a translation
  my $self = shift;
  my %args = @_;
  
  $self->{error} = undef; # reset the error object
  
  if(my $badNumOfStrings = checkForStrings($args{q})){ # check to make sure we have something - but not too much - to translate
    $self->{error} = $badNumOfStrings;
    return undef;
  }
  
  my $queryParams = { # set up the hash of params we'll need
    key => $self->{key},
    target => (gtg($args{target})) ? $args{target} : DEFAULT_TARGET_LANGUAGE,
    'format' => DEFAULT_STRING_FORMAT,
    q => $args{q}
  };
  foreach my $param (qw~prettyprint format source~) {
    if(gtg($args{$param})) {
      $queryParams->{$param} = $args{param};
    }
  }
      
  my $json;
  my $response = $self->{ua}->post(BASE_URL, $queryParams); # send and receive the translation
  eval {
    $json = from_json($response->decoded_content);
  };
  if(($debug) || ($@ ne '')){ # in case of error, vomit whatever we got back
   warn qq~\n================ TRANSLATE ERROR ================\n\n~ . $response->decoded_content . qq~\n\n============== END TRANSLATE ERROR ==============\n~;
  }
  
  if($debug){
    print Dumper(\%args, $queryParams, $json);
  }

  if(defined($json->{error})){ # if we have an error message, let's make it accessible
    $self->{error} = $json->{error};
  }
  if((defined($json->{data})) && (defined($json->{data}->{translations}))){ # if we have translations, let's return them as an array
    return @{$json->{data}->{translations}};
  }else{
    return undef;
  }
}





# *************************************************************************************
#
# Usage:
# my @detections = $translator->detect( q => \@stringsToDetect, 'format' => $stringFormat );
#
# *************************************************************************************

sub detect{ # detect the language of given strings
  my $self = shift;
  my %args = @_;
  
  $self->{error} = undef; # reset the error object
  
  if(my $badNumOfStrings = checkForStrings($args{q})){ # check to make sure we have something - but not too much - to translate
    $self->{error} = $badNumOfStrings;
    return undef;
  }
  
  my $queryParams = { # set up the hash of params we'll need
    key => $self->{key},
    'format' => DEFAULT_STRING_FORMAT,
    q => $args{q}
  };
  foreach my $param (qw~prettyprint format~) {
    if(gtg($args{$param})) {
      $queryParams->{$param} = $args{param};
    }
  }

  my $json;
  my $response = $self->{ua}->post(BASE_URL . "/detect", $queryParams); # send and receive the translation
  eval {
    $json = from_json($response->decoded_content);
  };
  if(($debug) || ($@ ne '')){ # in case of error, vomit whatever we got back
    warn qq~\n================ DETECT ERROR ================\n\n~ . $response->decoded_content . qq~\n\n============== END DETECT ERROR ==============\n~;
  }
  
  if($debug){
    print Dumper(\%args, $queryParams, $json);
  }
  
  if(defined($json->{error})){ # if we have an error message, let's make it accessible
    $self->{error} = $json->{error};
  }
  if((defined($json->{data})) && (defined($json->{data}->{detections}))){ # if we have detections, let's return them as an array
    return @{$json->{data}->{detections}};
  }else{
    return undef;
  }
}




# *************************************************************************************
#
# Usage:
# my @languageEnum = $translator->getLanguageEnum( target => $targetLanguage );
#
# *************************************************************************************

sub getLanguageEnum{
  my $self = shift;
  my %args = @_;
  
  $self->{error} = undef; # reset the error object
  
  my $queryParams = {
    key => $self->{key},
    target => DEFAULT_TARGET_LANGUAGE
  };
  foreach my $param (qw~prettyprint target~) {
    if(gtg($args{$param})) {
      $queryParams->{$param} = $args{param};
    }
  }

  my $json;
  my $response = $self->{ua}->post(BASE_URL . "/languages", $queryParams); # send and receive the language enum
  eval {
    $json = from_json($response->decoded_content);
  };
  if(($debug) || ($@ ne '')){ # in case of error, vomit whatever we got back
    warn qq~\n================ LANGUAGE ENUM ERROR ================\n\n~ . $response->decoded_content . qq~\n\n============== END LANGUAGE ENUM ERROR ==============\n~;
  }
  
  if($debug){
    print Dumper(\%args, $queryParams, $json);
  }
  
  if(defined($json->{error})){ # if we have an error message, let's make it accessible
    $self->{error} = $json->{error};
  }
  my %languageEnum;
  if((defined($json->{data})) && (defined($json->{data}->{languages}))){ # if we have languages, let's return them as an array
    my @languages = @{$json->{data}->{languages}};
    foreach my $lang (@languages){
      $languageEnum{$lang->{name}} = $lang->{language};
    }
  }
  return %languageEnum;
}




# utility functions
sub checkForStrings{ # check to make sure we don't have too many - or too few - strings. Returns undef if GOOD, error object if BAD
  my @strings;
  eval{
   @strings = @{$_[0]};
  };
  if($@ ne ''){
    @strings = @_;
  }
  if((@strings == 0) || (@strings > 128)){ # we'll check to make sure we (a) have something to translate and (b) don't have too much to translate
    return {
      errors => [
        {
          domain => "global",
          reason => "required",
          message => (@_ == 0) ? INSUFFICIENT_STRINGS_MESSAGE : TOO_MANY_QUERY_STRINGS_MESSAGE
        }
      ],
      code => 400,
      message => (@_ == 0) ? INSUFFICIENT_STRINGS_MESSAGE : TOO_MANY_QUERY_STRINGS_MESSAGE
    }
  }
  return undef;
}

sub gtg{ # check to see if a var is "good to go" by checking if it's defined and non-whitespace
  my $v = shift;
  return ((defined($v)) && ($v =~ /\S/)) ? 1 : 0;
}

return 1;
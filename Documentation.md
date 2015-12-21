# Name #

gtranslate-v2-pm is a perl module for interfacing the Google Translate API v2.

# Synopsis #

```
use GTranslateV2;

my $apiKey = "YOUR_API_KEY_HERE";
my $translator = GTranslateV2->new( key => $apiKey ); # initialize the translator

# get the languages we can use
print "\nSupported languages:\n";
my @languageEnum = $translator->getLanguageEnum( target => 'en' );
foreach my $lang (@languageEnum){ # print a list of the supported languages
  print $lang->{name} . " (" . $lang->{language} . ")\n";
}


# let's detect some languages!
print "\nLanguage detection:\n";
my @stringsToDetect = (
  'Hello, world!',
  'How are you?',
  'I love you!'
);
my @detections = $translator->detect( q => \@stringsToDetect );
for(my $i=0; $i < @detections; $i++){
  my $detection = $detections[$i]->[0];
  print $stringsToDetect[$i] . " -> " . $detection->{language} . " (" . $detection->{confidence} . ")\n";
}


# let's run a translation!
print "\nTranslation:\n";
my @stringsToTranslate = (
  'Hello, world! How are you today?'
);
my @translations = $translator->detect( q => \@stringsToTranslate, target => 'de' );
for(my $i=0; $i < @translations; $i++){
  print $stringsToTranslate[$i] . " -> " . $translations[$i]->{translatedText} . "\n";
}

```

# Installation #

Utilizing gTranslateV2.pm is intended to be fairly straightforward. But first, you need to install the module. At present, there is no Makefile.pl, configure, etc. Rather, install is done simply by adding the file gTranslateV2.pm (in the lib directory of the distro) to a directory in your @INC array or by including the appropriate folder with a use lib... statement. At some point, this will probably change, but not until more of the project is finalized and the module is ready for CPAN.

# Description #

GTranslateV2 is a Perl interface to the Google Translate API v2. The GTranslate API can provide translate text between a variety of languages. In order to utilize the service, you must sign up for your own API key via the [Google API Console](http://code.google.com/apis/console).

## Object constructor ##

You can use the following constructor to build your translator object:

```
my $translator = GTranslateV2->new( key => [YOUR_API_KEY] );
```

## Class Methods ##

Once you've created your translator object, you can use its three primary methods to interact with the API:

**getLanguageEnum( target => $targetLanguage )** Returns a hash listing the supported languages and their codes. The one argument:

  * **target** (optional) may be a valid language code supported by the API.

The hash has the following structure:

```
(
  humanFriendlyLanguageName => languageCode
)
```

```
my %languages = $translator->getLanguageEnum( target => 'de' );
```

**detect( q => \@stringsToDetect, 'format' => $stringFormat )** Returns an array of arrays which will contain details about the detected language of the given string(s). A couple of notes about the arguments:

  * **q** (required) may be either a simple string scalar or an array reference. If an array reference, the array must contain a series of strings.
  * **format** (optional) may be either **html** or **text**. If you provide no value, the default is **text** (which is different from the API's standard default).

The detections array has the following structure:

```
(
  {
    language => languageCode,
    confidence => howSureAmI,
    isReliable => amIReallySure
  }
)
```

NOTE: Generally, isReliable is not particularly reliable.

```
my @detections = $translator->detect( q => "Hello, world!" );
```

**translate( q => \@stringsToTranslate, source => $srcLanguage, target => $destLanguage, 'format' => $stringFormat)** Returns an array of hash references which will contain the translation(s). A couple of notes about the arguments:

  * **q** (required) may be either a simple string scalar or an array reference. If an array reference, the array must contain a series of strings.
  * **target** (required) must be a valid language code supported by the API. This specifies the language to which you want the string(s) translated. To obtain a list of codes, use $translator->getLanguageEnum()
  * **source** (optional) may be a valid language code supported by the API. This specifies the original language of the string(s) you want to translate. While supplying this is not required (Google's servers will attempt to detect the source language for you), it will improve performance if you can provide it.
  * **format** (optional) may be either **html** or **text**. If you provide no value, the default is **text** (which is different from the API's standard default).

The translations array has the following structure:

```
(
  {
    translatedText => yourStringTranslated,
    detectedSourceLanguage => languageCode
  }
)
```

NOTE: detectedSourceLanguage is only present if you do NOT provide the source argument yourself.

```
my @translations = $translator->translate( q => "Hello, world!", target => "de", source => "en" );
```

## Other tricks ##

**GTranslateV2::gtg( $scalar )** is a very simple test to see if the provided scalar is (a) defined and (b) contains non-whitespace characters.

# Author #
gTranslate.pm is maintained by the members of the gtranslate-v2-pm project, hosted at Google Code:

http://code.google.com/p/gtranslate-v2-pm
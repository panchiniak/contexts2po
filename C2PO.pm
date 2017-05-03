package Text::C2PO;

use warnings;
use strict;
use utf8;
use Data::Dumper qw(Dumper);
use List::MoreUtils qw(uniq);
use Locale::Language;
use File::Copy;
use Tie::File;
use 5.010;
use File::Find::Rule;
use Cwd 'abs_path';
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);

my $base_file_name;
my $translation_file_name;
my $context_file_name;
my $language_code;
my $verbose_mode;

my $current_path = abs_path(__FILE__);
my $current_file_name = __FILE__;

my $last_id_inserted;

#perl -f C2PO.pm --base [FILE_NAME] --translation [FILE_NAME] --context [FILE_NAME] --lang [LANGUAGE_CODE|list] --verbose

GetOptions(
    'base|b=s' => \$base_file_name,
    'translation|t=s' => \$translation_file_name,
    'context|c=s' => \$context_file_name,
    'lang|l=s' => \$language_code,
    'verbose' => \$verbose_mode,
) or die "Usage: $0 --base <FILE_NAME> --translation <FILE_NAME> --context <FILE_NAME> --lang <LANGUAGE_CODE>|list --verbose\n";

if ($language_code eq 'list'){
  my @language_codes = all_language_codes();
  my @language_names = all_language_names();

  foreach my $language (@language_codes) {
    print $language . " - " . code2language($language) . "\n" ;
  }
  exit;
}

#@TODO: Check if language code is actually in codes list.
if (not defined $language_code){
  print "Error: you have to choose a language according to ISO 622 codes. Use [list] to see all codes available.\n";
  exit;
}

#@TODO: Check if base, translation and contexts were defined.
my $po_file_name = "en-$language_code.po";

for ($current_path){
  s/$current_file_name/files/;
}

my @files = ($base_file_name, $translation_file_name, $context_file_name);

foreach my $file (@files){
  if (not -e "$current_path/$file"){
    print "Error: file $current_path/$file does not exist" . "\n";
    exit;
  }
}

#sub preprocess_base_translation{
#  #1. Convert line ends to unix: s/\r\n/\n/
#  #2. Remove single spaces: s/\s\n/\n/
#  #3. Remove empty lines: s/\n\n/\n/
#  #4. Remove marquers from options: s/\n• \s/\n/
#}
#
#sub preprocess_context{
#  #1. Put all msgids in single line: s/"\n"//  
#}

open (FH_B, "< $current_path/$base_file_name") or die "Can't open $current_path/$base_file_name for read: $!";
my @base_lines = <FH_B>;
my $base_file_count = $.;

open (FH_T, "< $current_path/$translation_file_name") or die "Can't open $current_path/$translation_file_name for read: $!";
my @tranlation_lines = <FH_T>;
my $translation_file_count = $.;

open (FH_CIN, "< $current_path/$context_file_name") or die "Can't open $current_path/$context_file_name for read: $!";
my @context_lines = <FH_CIN>;

open (our $outfile, "> $current_path/$po_file_name") or die "Can't open $current_path/$po_file_name for write: $!";


#Assure base and translation have the same number of lines
if ($translation_file_count != $base_file_count){
  print "Error: file $current_path/$base_file_name has $base_file_count lines and $current_path/$translation_file_name has $translation_file_count lines. They should have the same number of lines." . "\n";
  exit;
}

sub createPOentry {
  print { $_[0] ? \*STDOUT : $outfile } $_[1] . ' "' . $_[2] . '"' . "\n";
}

my $line_index = 0;
foreach my $base_line (@base_lines){
  my @brothers = ($base_line, $tranlation_lines[$line_index]);
  my $pair_index = 0;
  foreach my $brother (@brothers){
    chomp($brother);
    
    if ($pair_index == 0) {
      my $context_index = 0;
      foreach my $context_line (@context_lines){
      
        if ($context_line =~ /\Q$brother"\E/){
          #There is a matching msgid in context file.
          
           chomp($tranlation_lines[$line_index]);
           
           $last_id_inserted = $brother;
           
           if ($verbose_mode) {
              #Include comment line comming from context file.
              #@TODO: detect the absence of full context description.
              print $context_lines[$context_index - 2];
              print $context_lines[$context_index - 1];
              #@TODO: detect the presence of msid_plural format.
              createPOentry(1, 'msgid', $brother);
              createPOentry(1, 'msgstr', $tranlation_lines[$line_index]);
           }

           print $outfile $context_lines[$context_index - 2];
           print $outfile $context_lines[$context_index - 1];
           createPOentry(0, 'msgid', $brother);
           createPOentry(0, 'msgstr', $tranlation_lines[$line_index]);

        }
        $context_index++;
      }
      
    }
    else{
      #Also include pairs which msgid is absent from context.
      chomp($base_line);

      if (! defined $last_id_inserted) {
        $last_id_inserted = '';
      }

      if ($last_id_inserted ne $base_line) { 
        if ($verbose_mode) {
          createPOentry(1, 'msgid', $base_line);
          createPOentry(1, 'msgstr', $brother);
        }
        createPOentry(0, 'msgid', $base_line);
        createPOentry(0, 'msgstr', $brother);
      }
    }
    $pair_index = 1;
  }

  $line_index++;
}

__END__
=head1 Context POgenerator
Generates PO files from english base and its arbitrary aligned translation.

=head1 Preprocessing

A. On base and translation:

0. Adjust enconding for UTF-8
1. Convert line ends to unix: s/\r\n/\n/
2. Remove single spaces: s/\s\n/\n/
3. Remove empty lines: s/\n\n/\n/
4. Remove marquers from options: s/\n• \s/\n/

B. On context:
0. Adjust enconding for UTF-8
1. Put all msgids in single line: s/"\n"//

=head1 SYNOPSIS
Usage perl -f C2PO.pm --base [FILE_NAME] --translation [FILE_NAME] --context [FILE_NAME] --lang [LANGUAGE_CODE|list] --verbose
Options:
  base                  translated strings (msgid)
  translations          translations aligned to base (msgstr)
  context               POT (msgctxt, msgid)
  lang                  sufix for output file name

=head1 DESCRIPTION
Context to PO (C2PO) generates a PO file from POT, base and translated files.
PO generated contains comments, msgctxt, msgid, msgstr.
=head1 AUTHOR
Rodrigo Panchiniak Fernandes

=head1 CAVEAT
Base file and its translantion need to be aligned line by line.
=head1 ACKNOWLEDGMENTS
=cut

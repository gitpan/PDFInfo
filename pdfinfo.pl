#!/usr/local/bin/perl
# pdfinfo         -- a perl script to modify Info dictionary in PDF files
#
# by Fabrizio Pivari <pivari@geocities.com.it> 10 Jannuary 1998
#                    http://www.geocities.com/CapeCanaveral/Lab/3469/
#
# Copy, use, and redistribute freely, but don't take my name off it and
# clearly mark an altered version.  Fixes and enhancements cheerfully 
# accepted.
#
# This is the version 1.0.
#

$version="1.0";
$configure="pdfinfo.cfg";
require "newgetopt.pl";
do NGetOpt("help","author","creator","producer",
           "datecreation","moddate") || &printusage ;  
@elem=("PDF_Author","PDF_Creator","PDF_Producer","PDF_CreationDate",
       "PDF_ModDate");
%option=(
      PDF_Author       => 'Fabrizio Pivari pivari@geocities.com',
      PDF_Creator      => "PDFInfo version $version",
      PDF_Producer     => "PDFInfo version $version",
      PDF_CreationDate => "D: 196401250125+01'00'",
      PDF_ModDate      => "D: 196401250125+01'00'");
if ($opt_help) {&printusage};
open (CNF, "$configure") || die "Error: $configure - $!\n";
while (<CNF>)
   {
   s/\t/ /g;  #replace tabs by space
   next if /^[ \t]*\#/; #ignore comment lines
   next if /^[ \t]*$/;  #ignore empty lines
   foreach $elem (@elem) 
      {if (/[ \t]*$elem[ \t]*:[ \t]*(.*)/i) {$option{$elem}=$1;}}
   }
close(CNF);
$passwd=$opt_passwd;
if (@ARGV)
   {
   foreach $x (@ARGV)
      {
      $authorcounter=0; $creatorcounter=0; $producercounter=0;
      $creationdatecounter=0; $moddatecounter=0;
      $file = $x;
      $old = $file;
      $new = "$file.tmp.$$";
      $bak = "$file.bak";
      open(OLD, "< $old") or die "can't open $old: $!";
      open(NEW, "> $new") or die "can't open $new: $!";
      # Correct typos, preserving case
      while (<OLD>)
         {
         if ((/\/Author/i .. /\)\n/) && ($opt_author))
            {
            $authorcounter++;
            if ($authorcounter eq 1)
               {
               print NEW qq!/Author($option{'PDF_Author'})\n!;
               }
            }
         elsif ((/\/Creator/i .. /\)\n/) && ($opt_creator))
            {
            $creatorcounter++;
            if ($creatorcounter eq 1)
               {
               print NEW qq!/Creator($option{'PDF_Creator'})\n!;
               }
            }
         elsif ((/\/Producer/i .. /\)\n/) && ($opt_producer))
            {
            $producercounter++;
            if ($producercounter eq 1)
               {
               print NEW qq!/Producer($option{'PDF_Producer'})\n!;
               }
            }
         elsif ((/\/CreationDate/i .. /\)\n/) && ($opt_datecreation))
            {
            $creationdatecounter++;
            if ($creationdatecounter eq 1)
               {
               print NEW qq!/CreationDate($option{'PDF_CreationDate'})\n!;
               }
            }
         elsif ((/\/ModDate/i .. /\)\n/) && ($opt_moddate))
            {
            $moddatecounter++;
            if ($moddatecounter eq 1)
               {
               print NEW qq!/ModDate($option{'PDF_ModDate'})\n!;
               }
            }
         else {(print NEW $_) or die "can't write to $new: $!";}
         }
      close(OLD) or die "can't close $old: $!";
      close(NEW) or die "can't close $new: $!";
      rename($old, $bak) or die "can't rename $old to $bak: $!";
      rename($new, $old) or die "can't rename $new to $old: $!";
      }
   }

sub printusage {
    print <<USAGEDESC;

usage:
        pdfinfo [-options ...] PDF_files

where options include:
    -author                      change the original /Author() field with the
                                 specified in configuration file
    -creator                     change the original /Creator() field with the
                                 specified in configuration file
    -datecreation                change the original /CreationDate() field
                                 with the specified in configuration file
    -moddate                     change the original /ModDate() field with the
                                 specified in configuration file
    -producer                    change the original /Producer() field with
                                 the specified in configuration file
    -help                        print out this message

PDF_files:
    with files you can use metacharacters and relative and absolute path name
    
example:
    pdfinfo *.pdf
    pdfinfo -h
    pdfinfo -a -p -v

If you want to know more about this tool, you might want
to read the docs. They came together with pdfinfo!

Home: http://www.geocities.com/CapeCanaveral/Lab/3469/pdfinfo.html

USAGEDESC
    exit(1);
}

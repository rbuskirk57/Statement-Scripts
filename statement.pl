use 5.012; # AFT scripts should use at least perl 5.012.  This also enables 'strict' mode.
use strict;
use Carp;
use warnings;       # turn on checking for various common issues
use File::Slurp;    # adds a tool to read in an entire file.

# Args:
# Source; category file;
my ( $source_file, $catagory_list ) = @ARGV;

my ($path)             = $source_file =~ /^(.+\\+)/;
my ($source_file_name) = $source_file =~ /^.+\\+(\w+)/;
my $out_file = $path . "\\" . $source_file_name . "_cat.CSV";
my $line;
my $catagory;

sub GetCatagory()
{
   my $cat_line;
   my $new_line = "";
   
   open my $fh, '<', $catagory_list or croak "Cannot open $catagory_list!\n";
   
   while ($cat_line = <$fh>)
    {
       my ( $pattern, $catagory ) = split "::", $cat_line;

       if ( ( "$pattern" =~ /^\s*$/ ) || "$pattern" =~ /^#/ )
       {
          #ignore blank or comment lines
       }
       else
       {
          if ($line =~ m/$pattern/i)
          {
             chomp $line;
             $new_line = $line . "$catagory";
             last if ($new_line);
          }
       }
    }
    close($fh) || croak "Cannot close $fh!\n";
    if(!$new_line)
    {
       chomp $line;
       $new_line = $line . "undef\n";
    }
    return $new_line;
}

open( INSOURCE, "<$source_file" )    || die($!);
open( OUT,      ">$out_file" ) || die($!);

while ( $line = <INSOURCE> ) {
   if($line =~ /Posting/)
   {
      $line =~ s/(Details,)//;
      $line =~ s/( or Slip #)//;
      $line =~ s/(Posting Date,Description,Amount,Type,Balance,Check)/Posting,Date,Description,Amount,Type,Balance,Check,Catagory/;
   }
   else
   {
      # get_catagory()
      $line = GetCatagory();
   }
   print $line;

   print OUT $line;
}

close(INSOURCE);
close(OUT);
# gen_flash.pl
# Author: Samuel Sugimoto
# Date:   

$filename = 'test_flash.dat';
open(FP, ">$filename");

$counter = 0;
$bits_32 = 4294967296; # 2^32
for($i = 0; $i < 16384; $i++)
{
  $rand32_0 = int(rand($bits_32));
  $rand32_1 = int(rand($bits_32));
  if($i == 16383) {
    print FP sprintf("%08X%08X", $rand32_1, $rand32_0);
  } else {
    print FP sprintf("%08X%08X\n", $rand32_1, $rand32_0);
  }
}
close(FP);

--TEST--
Eval blacklist - nested eval, with a twist
--SKIPIF--
<?php if (!extension_loaded("snuffleupagus")) die "skip"; ?>
--INI--
sp.configuration_file={PWD}/config/eval_backlist.ini
--FILE--
<?php 
$a = strlen("1337 1337 1337");
echo "Outside of eval: $a\n";
eval(
	"echo 'Inception lvl 1...\n';
   eval(
     'echo \"Inception lvl 2...\n\";
      eval(
				 \"echo \'Inception lvl 3...\n\';
       \");
			 strlen(\'Limbo!\');
   ');
");
echo "After eval: $a\n";
?>
--EXPECTF--
Outside of eval: 14
Inception lvl 1...
Inception lvl 2...
Inception lvl 3...

Fatal error: [snuffleupagus][eval] A call to strlen was tried in eval, in %a/nested_eval_blacklist2.php(5) : eval()'d code:7, dropping it. in %a/nested_eval_blacklist2.php(5) : eval()'d code(4) : eval()'d code on line 7
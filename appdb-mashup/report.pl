#!/usr/bin/perl
# Generates an html report with one row for each highly rated app that works well in Wine.
# Has columns linking to the appdb, the source of rating info, and various searches about the app.

# Load in various tables

open(FILE, "gamerank-scores.txt") || die;
while (<FILE>) {
   chomp;
   /(\d*)	([^	]*)/ || die;
   $gamerank_scores{$1} = $2;
}
close(FILE);

open(FILE, "gamerank-years.txt") || die;
while (<FILE>) {
   chomp;
   /(\d*)	([^	]*)/ || die;
   $gamerank_years{$1} = $2;
}
close(FILE);

open(JOINEDSCORES, "joined-scores.txt") || die;
foreach (<JOINEDSCORES>) {
  chomp;
  # Format:
  # appdbid     title           grid    appdb-score
  # 10059	The Hunter	954010	Garbage 
  /(\d*)	([^	]*)	(\d*)	([^	]*)/ || die;
  $appdb_id = $1;
  $title = $2;
  $gamerankings_id = $3;
  $appdb_scores = $4;
  #print "got appdb_id $appdb_id title $title gamerankings_id $gamerankings_id appdb_scores $appdb_scores\n"; 

  # Fixme: dedup appdb_scores earlier
  undef %dedup;
  foreach $score (split(" ", $appdb_scores)) {
    $dedup{$score}++;
  }
  $appdb_scores="";
  foreach $score (sort(keys(%dedup))) {
    $appdb_scores .= "$score ";
  }
  next if ($appdb_scores !~ /Gold|Platinum/);

  $purename = $title;
  $purename =~ s/&//;
  $year = $gamerank_years{$gamerankings_id};
  $gamerank_score = $gamerank_scores{$gamerankings_id};

  $rows{$title} = "<tr>\
<td>$title</td> \
<td>$year</td> \
<td><a href=\"http://www.gamerankings.com/pc/$gamerankings_id-/\">$gamerank_score</a></td> \
<td><a href=\"http://appdb.winehq.org/appview.php?appId=$appdb_id\">$appdb_scores</a></td> \
<td><a href=\"http://www.amazon.com/gp/search/ref=sr_nr_i_1?rh=i:software,k:PC+$purename\">Amazon</a></td> \
<td><a href=\"http://en.wikipedia.org/w/index.php?title=Special:Search&search=$purename&go=Go\">Wikipedia</a></td> \
<td><a href=\"http://google.com/search?q=PC+$purename+walkthrough\">Walkthroughs</a></td> \
";
}
print "<html><body><h1>Highly rated apps that work well in Wine</h1><table border=1>\n";
foreach $key (sort(keys(%rows))) {
  print $rows{$key};
}
print "</table></body></html>\n";
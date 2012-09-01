#!/usr/bin/env perl

use warnings;
use strict;

use Text::Markdown 'markdown';

local $/ = undef;
my $md = <>;
my ($title) = ($md =~ /^(.*)\n/m);
my $html = markdown($md);

# warn $title;

print <<EOF;
<!DOCTYPE html>
<html>
<head>
<title>$title</title>
<link rel="stylesheet" type="text/css" href="http://github.github.com/github-flavored-markdown/shared/css/documentation.css"/>
<style type="text/css">
div.container {margin-left: 10ex}
</style>
</head>
<body>
<div class="container">
<div class="content">
$html
</div>
</div>
</body>
</html>
EOF

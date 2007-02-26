package Hoster::Template;

#------------------------------
sub get {
	my ($template) = @_;
	my $content;
	open(FILE,"<$template");
	while(<FILE>) {
		$content .= $_;
	}
	close(FILE);
	return $content;
}

#------------------------------
sub parse {
	my ($template, $opts) = @_;
	foreach my $key (keys %{$opts}) {
		my $find = "__".$key."__";
		my $replace = $opts->{$key};
		$template =~ s/$find/$replace/g;
	}
	return $template;
}

#------------------------------
sub process {
	my ($template,$opts) = @_;
	return parse(get($opts->{'hoster-home'}.'/var/'.$template),$opts);
}

1;


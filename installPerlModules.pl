#!/data/wre/prereqs/perl/bin/perl
$|=1; # disable buffering
use CPAN;

my @modules = (
	{ module=>"BSD::Resource", force=>1 },
	{ module=>"URI" },
	{ module=>"IO::Zlib" },
	{ module=>"HTML::Tagset" },
	{ module=>"HTML::Parser" },
	{ module=>"LWP", force=>1 },
	{ module=>"CGI" },
	{ module=>"Digest::MD5" },
	{ module=>"Digest::SHA1" },
	{ module=>"Module::Build" },
	{ module=>"Params::Validate" },
	{ module=>"DateTime::Locale" },
	{ module=>"Class::Singleton" },
	{ module=>"DateTime::TimeZone" },
	{ module=>"Time::Local" },
	{ module=>"Test::More" },
	{ module=>"Devel::Symdump" },
	{ module=>"Pod::Escapes" },
	{ module=>"Pod::Coverage" },
	{ module=>"Pod::Man" },
	{ module=>"DateTime", force=>1 },
	{ module=>"DateTime::Format::Strptime" },
	{ module=>"DateTime::Cron::Simple" },
	{ module=>"Date::Manip" },
	{ module=>"HTML::Template" },
	{ module=>"Crypt::SSLeay" },
	{ module=>"Parse::PlainConfig" },
	{ module=>"String::Random" },
	{ module=>"Time::HiRes" },
	{ module=>"Text::Balanced" },
	{ module=>"Tie::IxHash" },
	{ module=>"Tie::CPHash" },
	{ module=>"Error" },
	{ module=>"Cache::Cache" },
	{ module=>"HTML::Highlight" },
	{ module=>"HTML::TagFilter" },
	{ module=>"IO::String" },
	{ module=>"Archive::Zip" },
	{ module=>"Archive::Tar" },
	{ module=>"XML::NamespaceSupport" },
	{ module=>"XML::SAX" },
	{ module=>"XML::Simple", force=>1 },
	{ module=>"XML::RSSLite" },
	{ module=>"SOAP::Lite" },
	{ module=>"DBI" },
	{ module=>"DBD::mysql", force=>1 },
	{ module=>"Convert::ASN1" },
	{ module=>"Authen::SASL" },
	{ module=>"HTML::TableExtract" },
	{ module=>"Finance::Quote" },
	{ module=>"JSON" },
	{ module=>"Net::SSLeay" },
	{ module=>"IO::Socket::SSL" },
	{ module=>"Net::LDAP" },
	{ module=>"Log::Log4perl" },
	{ module=>"POE" },
	{ module=>"POE::Component::IKC::Server" },
	{ module=>"POE::Component::JobQueue" },
	{ module=>"Parse::RecDescent" },
	{ module=>"DBIx::FullTextSearch", force=>1 },
	{ module=>"String::CRC32" },
	{ module=>"Cache::Memcached" },
	{ module=>"ExtUtils::XSBuilder::ParseSource" },
	{ module=>"trace" },
	{ module=>"Pod::Simple" },
	{ module=>"Test::Builder::Tester" },
	{ module=>"Clone" },
	{ module=>"Test::Pod" },
	{ module=>"Data::Structure::Util" },
	);

for $module (@modules) {
	my $cpan = CPAN::Shell->expand('Module',$module->{module});
	if (defined $cpan) {
		next if $cpan->inst_version;
		if ($module->{force}) {
			force("install",$module->{module});
		} else {
			$cpan->install;
		}
		unless ($cpan->inst_version) {
			die "$module->{module} failed to install!\n";
		}	
	} else {
		die "$module->{module} is not available on CPAN\n";
	}
}



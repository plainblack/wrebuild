
=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Plack::Builder;
use Plack::Util;
use WRE::Config;

builder {
    # use the first config found as a fallback
    my $wre_config = WRE::Config->new();
    if ($wre_config->get('demo/enabled')) {
        use WRE::WebguiDemo;
        my $wre = WRE::WebguiDemo->new();
        mount $wre_config->get('demo/hostname') => $wre->to_app;
    }
    my $webgui = Plack::Util::load_psgi($wre_config->getWebguiRoot('app.psgi'));
    mount '/' => $webgui;
};


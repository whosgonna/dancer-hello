#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use Dancer2::Hello;

Dancer2::Hello->to_app;

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use Dancer2::Hello;
use Plack::Builder;

builder {
    enable 'Deflater';
    Dancer2::Hello->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to mount several applications on different path

use Dancer2::Hello;
use Dancer2::Hello_admin;

use Plack::Builder;

builder {
    mount '/'      => Dancer2::Hello->to_app;
    mount '/admin'      => Dancer2::Hello_admin->to_app;
}

=end comment

=cut


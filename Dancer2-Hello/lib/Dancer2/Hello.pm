package Dancer2::Hello;
use Dancer2;

our $VERSION = '0.1';

get '/' => sub {
    template 'index' => { 'title' => 'Dancer2::Hello' };
};

get '/:name' => sub {
    my $name = route_parameters->get('name');

    template 'index' => {
        title => "Dancer2::Hello::$name",
        name  => $name,
    }
};

true;

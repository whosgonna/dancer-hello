## The core elements of the stack
requires 'Dancer2';
requires 'Gazelle';
requires 'Dancer2::Template::TemplateToolkit';


## Dancer2 recommends this modules to improve your app
## performance
suggests 'CGI::Deurl::XS';
suggests 'HTTP::Parser::XS';
suggests 'HTTP::XSCookies';
suggests 'Scope::Upper';
suggests 'Type::Tiny::XS';
suggests 'URL::Encode::XS';


on 'develop' => sub {
    requires 'Data::Printer';
};

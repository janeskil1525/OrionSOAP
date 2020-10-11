package OrionSOAP;
use Mojo::Base -base;

use XML::Compile::WSDL11;
use XML::Compile::SOAP12;
use XML::Compile::Transport::SOAPHTTP;
use Mojo::File;

sub get_wsdl {

    my $path = Mojo::File->new('/home/jan/Project/OrionSOAP/wsdl/SoapIntegrationService.wsdl');
    my $wsdlfile = $path->slurp;

    my $wsdl = XML::Compile::WSDL11->new($wsdlfile
        , server_type => 'Microsoft'
    );

    my $xml->{carbreaker}   = 'F';
        $xml->{ partid }          = '22569490';
        $xml->{ reservationtype } = 2;
        $xml->{ id }              = 0;
        $xml->{ extreference }    = 'Osatt';
        $xml->{ extsource }       = 'LagaPro';
        $xml->{ usersign }        = 'Jan';



    my $call = $wsdl->compileClient(
        operation => 'SaveReservations',
        port      => 'WSHttpBinding_ISoapIntegrationService',
        portType  => 'URL',
    );

    my $answer = $call->($xml);


}

1;
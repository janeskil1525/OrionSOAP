package OrionSOAP;
use Mojo::Base -base;

use XML::Compile::WSDL11;
use XML::Compile::SOAP12;
use XML::Compile::Transport::SOAPHTTP;
use Mojo::File;
use Data::Dumper;


sub get_wsdl {

    my $path = Mojo::File->new('/home/jan/Project/OrionSOAP/wsdl/SoapIntegrationService.wsdl');
    my $wsdlfile = $path->slurp;

    my $wsdl = XML::Compile::WSDL11->new($wsdlfile,
        #, server_type => 'Microsoft'
        envelope_ns => ''
    );
    $wsdl->addWSDL('/home/jan/Project/OrionSOAP/wsdl/opencarpartinterface.wsdl');
    $wsdl->importDefinitions('/home/jan/Project/OrionSOAP/wsdl/SystemServiceModel.xml');

    #say $wsdl->explain('SaveReservations', PERL => 'INPUT', recurse => 1, port => 'WSHttpBinding_ISoapIntegrationService',);
    #say $wsdl->explain('SaveReservations', PERL => 'OUTPUT', port => 'WSHttpBinding_ISoapIntegrationService',);
    my $xml;
    $xml->{carbreaker}   = 'F';
    $xml->{ partid }          = '22569490';
    $xml->{ reservationtype } = 2;
    $xml->{ id }              = 0;
    $xml->{ extreference }    = '12345';
    $xml->{ extsource }       = 'LagaPro';
    $xml->{ usersign }        = 'Jan';

    #my %xml = ('carbreaker', 'F', 'partid', 22569490, 'reservationtype', 2, 'id', 0, 'extreference', 'Tom', 'extsource', 'LagaPro', 'usersign', 'Jan');

    my $xmlmess;
    push @{$xmlmess->{reservations}->{Reservation}}, $xml;
    #$xmlmess->{reservations} = %xml;

    my $call = $wsdl->compileClient(
        operation => 'SaveReservations',
        port      => 'WSHttpBinding_ISoapIntegrationService',
        #portType  => 'operation',
        # block_namespace => 'http://www.w3.org/2003/05/soap-envelope',
    );

    my ($answer, $trace) = $call->($xmlmess);

say $trace;
say Dumper($answer);
}

1;
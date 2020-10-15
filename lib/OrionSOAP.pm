package OrionSOAP;
use Mojo::Base -base;

use XML::Compile::WSDL11;
use XML::Compile::SOAP12;
use XML::Compile::Transport::SOAPHTTP;
use Mojo::File;
use Mojo::UserAgent;
use Data::Dumper;
use HTTP::Headers;
use XML::Hash::XS;
use LWP::UserAgent;
use HTTP::Request;

sub get_wsdl {
    my $self = shift;

    my $h = HTTP::Headers->new();
    $h->header('Content-Type' => 'text/xml; charset=utf-8');
    $h->header('Authorization' => 'Fenix Norr:q81k');

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

sub get_stockitem {
    my $self = shift;

    my $path = Mojo::File->new('/home/jan/Project/OrionSOAP/wsdl/SoapIntegrationService.wsdl');
    my $wsdlfile = $path->slurp;

    my $h = HTTP::Headers->new();
    $h->header('Content-Type' => 'text/xml; charset=utf-8');
    $h->header('Authorization' => 'Fenix Norr:q81k');

    my $http = XML::Compile::Transport::SOAPHTTP->new();
    my $send = $http->compileClient(
        header    => $h,
    );

    my $wsdl = XML::Compile::WSDL11->new(
        #, server_type => 'Microsoft'
        #endpoint  => 'http://testws.bosab.se/RestIntegrationService.svc/pox/GetPart?id=22569490'

    );

    $wsdl->addWSDL('/home/jan/Project/OrionSOAP/wsdl/opencarpartinterface.wsdl');
    $wsdl->importDefinitions('/home/jan/Project/OrionSOAP/wsdl/SystemServiceModel.xml');
    $wsdl->operation('GetPart', 'service' => 'ISoapIntegrationService_GetPart_InputMessage');
    my $call = $wsdl->compileClient(
        transport => $send,
        operation => 'GetPart',
        port      => 'WSHttpBinding_ISoapIntegrationService',
        service   => 'ISoapIntegrationService_GetPart_InputMessage',
        #portType  => 'operation',
        # block_namespace => 'http://www.w3.org/2003/05/soap-envelope',
    );

    my $xml->{id} = 22569490;
    my ($answer, $trace) = $call->($xml);

    say $trace;
    say Dumper($answer);
}

sub get_with_useragent {
    my $self = shift;

    my $ua = Mojo::UserAgent->new();
    my $headers;
    $headers->{'Content-Type'} = 'text/xml; charset=utf-8';
    $headers->{Authorization} = 'Fenix Norr:q81k';
    my $res = $ua->get('http://testws.bosab.se/RestIntegrationService.svc/pox/GetPart?id=22569490' => $headers)->result;

    say $res->body;
    say 'The End';
}

sub test_xml_xs {

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
    #push @{$xmlmess->{reservations}->{Reservation}}, $xml;

    my $conv   = XML::Hash::XS->new(utf8 => 0, encoding => 'utf-8');

    my $xmlstr = $conv->hash2xml(
        {
            xmlns => 'http://opencarpartinterface.org/2011/09',
            reservations => [
                {
                    Reservation => {
                        carbreaker      => [ 'F' ],
                        partid          => [ '22569490' ],
                        reservationtype => [ 2 ],
                        id              => [ 0 ],
                        extreference    => [ '12345' ],
                        extsource       => [ 'LagaPro' ],
                        usersign        => [ 'Jan' ],
                    }
                }
            ]
        },
        utf8 => 1,
        root => 'SaveReservations',
        use_attr  => 1,
        canonical => 1,
    );
    # my $pos = index($xmlstr, 'SaveReservations');
    # my $new_xmlstr = substr($xmlstr,0,$pos) .
    #     'SaveReservations xmlns = "http://opencarpartinterface.org/2011/09"' .
    #     substr($xmlstr,$pos + length('SaveReservations'));



    say $xmlstr;

    my $ua = LWP::UserAgent->new();
    my $request = HTTP::Request->new(POST => 'http://testws.bosab.se/RestIntegrationService.svc/pox/SaveReservations');
    $request->content_type("text/xml; charset=utf-8");
    $request->content($xmlstr);
    $request->header(Authorization => 'Fenix Norr:q81k', 'Content-Type' => "text/xml; charset=utf-8");

    my $response = $ua->request($request);

    if($response->is_success) {
        print $response->decoded_content;

        my $xml_result = $conv->xml2hash($response->decoded_content);
        say Dumper($xml_result);
    }
    else {
        print $response->error_as_HTML;
    }

}
1;
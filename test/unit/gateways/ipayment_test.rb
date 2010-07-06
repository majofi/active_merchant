require 'test_helper'

class IpaymentTest < Test::Unit::TestCase
  def setup
    @gateway = IpaymentGateway.new(
                 :account_id => '99999',
                 :application_id => '99999',
                 :application_pw => '0',
                 :admin_pw => '5cfgRT34xsdedtFLdfHxj7tfwx24fe'
               )

    @credit_card = credit_card
    @amount = 100
    
    @options = { 
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase'
    }
  end

  def test_no_authorization
    assert_raise(StandardError){ @gateway.authorize(1, 'cc') }
  end

  def test_no_purchase
    assert_raise(StandardError){ @gateway.purchase(nil, nil)}
  end

  def test_generate_session_id
    @gateway.expects(:do_soap_request).returns(successful_session_id_request)
    assert_equal 'MYSESSIONID', @gateway.generate_session_id(13, 'EUR', 'preauth', 'www.redirect.de', 'www.error.de')
  end

  def test_generate_session_id_error
    @gateway.expects(:do_soap_request).returns(failed_session_id_request)
    assert_raise(StandardError){@gateway.generate_session_id(13, 'EUR', 'preauth', 'www.redirect.de', 'www.error.de')}
  end

  def test_capture
    @gateway.expects(:do_soap_request).returns(successful_caputure_request)
    @gateway.expects(:build_capture_request).with('9-87654', 13, 'EUR')
    assert(@gateway.capture(13, 'EUR', '9-87654'))
    assert_equal('1-1234567', @gateway.last_trx_number)
  end

  def test_failed_capture
    @gateway.expects(:do_soap_request).returns(failed_capture_request)
    @gateway.expects(:build_capture_request).with('9-87654', 0, 'USD')
    assert_raise(StandardError){@gateway.capture(0, 'USD', '9-87654')}
  end

  def test_refund
    @gateway.expects(:do_soap_request).returns(successful_refund_request)
    @gateway.expects(:build_refund_request).with('555555', 15, 'EUR')
    assert(@gateway.refund(15,'EUR', '555555'))
    assert_equal('999999', @gateway.last_trx_number)
  end

  def test_failed_refund
    @gateway.expects(:do_soap_request).returns(failed_refund_request)
    @gateway.expects(:build_refund_request).with('9-87654', 0, 'USD')
    assert_raise(StandardError){@gateway.refund(0, 'USD', '9-87654')}
  end

  private

  def successful_refund_request
    xml = "<?xml version='1.0' encoding='ISO-8859-1'?>
            <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'>
              <SOAP-ENV:Body>
                <ns1:refundResponse xmlns:ns1='https://ipayment.de/service_v3/extern'>
                  <ipaymentReturn>
                    <status xmlns=''>SUCCESS</status>
                    <successDetails xmlns=''>
                      <retTransDate xmlns=''>06.07.10</retTransDate>
                      <retTransTime xmlns=''>15:27:16</retTransTime>
                      <retTrxNumber xmlns=''>999999</retTrxNumber>
                      <retAuthCode xmlns=''/>
                    </successDetails>
                    <addressData xmlns=''>
                      <addrStreet xmlns=''>Qeuchstr. 12</addrStreet>
                      <addrCity xmlns=''>Landau</addrCity>
                      <addrZip xmlns=''>76829</addrZip>
                      <addrCountry xmlns=''>DE</addrCountry>
                    </addressData>
                    <paymentMethod xmlns=''>MasterCard</paymentMethod>
                    <trxPaymentDataCountry xmlns=''>US</trxPaymentDataCountry>
                    <trxRemoteIpCountry xmlns=''>DE</trxRemoteIpCountry>
                  </ipaymentReturn>
                </ns1:refundResponse>
              </SOAP-ENV:Body>
            </SOAP-ENV:Envelope>"
    xml
  end

  def failed_refund_request
    xml = "<?xml version='1.0' encoding='ISO-8859-1'?>
            <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'>
              <SOAP-ENV:Body><ns1:refundResponse xmlns:ns1='https://ipayment.de/service_v3/extern'>
                <ipaymentReturn>
                  <status xmlns=''>ERROR</status>
                  <errorDetails xmlns=''>
                    <retErrorcode xmlns=''>1002</retErrorcode>
                    <retFatalerror xmlns=''>1</retFatalerror>
                    <retErrorMsg xmlns=''>Die Initialisierung der Transaktion ist fehlgeschlagen.</retErrorMsg>
                    <retAdditionalMsg xmlns=''/>
                  </errorDetails>
                </ipaymentReturn>
              </ns1:refundResponse>
            </SOAP-ENV:Body>
          </SOAP-ENV:Envelope>"

    xml
  end

  def successful_caputure_request
    xml = '<?xml version="1.0" encoding="ISO-8859-1"?>
            <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <SOAP-ENV:Body>
                <ns1:captureResponse xmlns:ns1="https://ipayment.de/service_v3/extern">
                  <ipaymentReturn>
                    <status xmlns="">SUCCESS</status>
                    <successDetails xmlns="">
                      <retTransDate xmlns="">06.07.10</retTransDate>
                      <retTransTime xmlns="">12:39:57</retTransTime>
                      <retTrxNumber xmlns="">1-1234567</retTrxNumber>
                      <retAuthCode xmlns=""></retAuthCode>
                    </successDetails>
                    <addressData xmlns="">
                        <addrStreet xmlns="">Qeuchstr. 12</addrStreet>
                        <addrCity xmlns="">Landau</addrCity>
                        <addrZip xmlns="">76829</addrZip>
                        <addrCountry xmlns="">DE</addrCountry>
                      </addressData>
                      <paymentMethod xmlns="">MasterCard</paymentMethod>
                      <trxPaymentDataCountry xmlns="">US</trxPaymentDataCountry>
                      <trxRemoteIpCountry xmlns="">DE</trxRemoteIpCountry>
                    </ipaymentReturn>
                  </ns1:captureResponse>
                </SOAP-ENV:Body>
              </SOAP-ENV:Envelope>'
    xml
  end

  def failed_capture_request
    xml = "<?xml version='1.0' encoding='ISO-8859-1'?>
            <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'>
              <SOAP-ENV:Body>
                <ns1:captureResponse xmlns:ns1='https://ipayment.de/service_v3/extern'>
                  <ipaymentReturn>
                    <status xmlns=''>ERROR</status>
                    <errorDetails xmlns=''>
                      <retErrorcode xmlns=''>1002</retErrorcode>
                      <retFatalerror xmlns=''>1</retFatalerror>
                      <retErrorMsg xmlns=''>Die Initialisierung der Transaktion ist fehlgeschlagen.</retErrorMsg>
                      <retAdditionalMsg xmlns=''/>
                    </errorDetails>
                  </ipaymentReturn>
                </ns1:captureResponse>
              </SOAP-ENV:Body>
            </SOAP-ENV:Envelope>"
    xml
  end

  def successful_session_id_request
    xml = '<?xml version="1.0" encoding="ISO-8859-1"?>
          <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SOAP-ENV:Body>
              <ns1:createSessionResponse xmlns:ns1="https://ipayment.de/service_v3/extern">
                <sessionId>MYSESSIONID</sessionId>
              </ns1:createSessionResponse>
            </SOAP-ENV:Body>
          </SOAP-ENV:Envelope>'
     xml
  end

  def failed_session_id_request
    xml = '<?xml version="1.0" encoding="ISO-8859-1"?>
            <SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"   xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"   xmlns:xsd="http://www.w3.org/2001/XMLSchema"   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"   xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/">
              <SOAP-ENV:Body><SOAP-ENV:Fault>
                <faultcode xsi:type="xsd:string">ERRORCODE</faultcode>
                <faultactor xsi:type="xsd:string"></faultactor>
                <faultstring xsi:type="xsd:string">Some error text</faultstring>
                <detail xsi:type="xsd:string"></detail>
              </SOAP-ENV:Fault>
            </SOAP-ENV:Body>
          </SOAP-ENV:Envelope>'
    xml
  end

  # Place raw successful response from gateway here
  def successful_purchase_response
  end
  
  # Place raw failed response from gateway here
  def failed_purchase_response
  end
end

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
    @gateway.expects(:do_soap_request).returns(successful_session_id_request);
    assert_equal 'MYSESSIONID', @gateway.generate_session_id(13, 'EUR', 'preauth', 'www.redirect.de', 'www.error.de')
  end

  def test_generate_session_id_error
    @gateway.expects(:do_soap_request).returns(failed_session_id_request);
    assert_raise(StandardError){@gateway.generate_session_id(13, 'EUR', 'preauth', 'www.redirect.de', 'www.error.de')}
  end

  private

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

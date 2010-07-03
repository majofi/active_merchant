module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class IpaymentGateway < Gateway

      SERVICE_URL = 'https://ipayment.de/service/3.0/'

      ENVELOPE_NAMESPACES = { 'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
                              'xmlns:SOAP-ENV' => 'http://schemas.xmlsoap.org/soap/envelope/',
                              'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
                            }
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['US'] #TODO
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.example.net/' #TODO
      
      # The name of the gateway
      self.display_name = 'New Gateway'
      
      def initialize(options = {})
        requires!(options, :account_id, :application_id, :application_pw, :admin_pw)
        @options = options
        super
      end  
      
      def authorize(money, creditcard, options = {})
        #not possible without PCI , use the "integration"
        raise StandardError, 'No authorisation possible, use integration'

        #post = {}
        #add_invoice(post, options)
        #add_creditcard(post, creditcard)
        #add_address(post, creditcard, options)
        #add_customer_data(post, options)
        
        #commit('authonly', money, post)
      end
      
      def purchase(money, creditcard, options = {})
        raise StandardError, 'No purchase possible, use integration'

        #post = {}
        #add_invoice(post, options)
        #add_creditcard(post, creditcard)
        #add_address(post, creditcard, options)
        #add_customer_data(post, options)
             
        #commit('sale', money, post)
      end                       
    
      def capture(money, currency, transaction_id)

        xml = build_capture_request transaction_id, money, currency

        return_xml = do_soap_request 'capture', xml

        data = REXML::Document.new(return_xml)

        result = data

        #TODO

        #commit('capture', money, post)
      end


      #calls ipayment webservice in order to create a
      #secure session id to identify account and amount
      #protects against fraud
      def generate_session_id money, currency, transaction_type, redirect_url,
                              error_url

        xml = build_session_request money, currency, transaction_type, redirect_url, error_url

        return_xml = do_soap_request 'createSession', xml

        data = REXML::Document.new(return_xml)
        session_element = REXML::XPath.first( data, "//sessionId")
        if session_element.nil?
          fault_code = REXML::XPath.first( data, "//faultcode").text
          fault_msg = REXML::XPath.first( data, "//faultstring").text
          raise StandardError, 'unable to generate ipayment session id ' + fault_code + ' ' +fault_msg
        else
          session_element.text
        end
      end

      

      private                       

      def build_capture_request transaction_id, money, currency
        xml = Builder::XmlMarkup.new :indent => 2
        xml.tag! 'origTrxNumber', transaction_id
        xml.tag! 'transactionData' do
          xml.tag! 'trxAmount', money
          xml.tag! 'trxCurrencyType', currency
        end
      end

      def build_session_request money, currency, transaction_type, redirect_url,
                              error_url

        xml = Builder::XmlMarkup.new :indent => 2
        xml.tag! 'transactionData' do
          xml.tag! 'trxAmount', money.to_s
          xml.tag! 'trxCurrencyType', currency
        end
        xml.tag! 'transactionType', transaction_type
        xml.tag! 'paymentType', 'cc' #TODO
        xml.tag! 'processorUrls' do
          xml.tag! 'redirectUrl', redirect_url
          xml.tag! 'silentErrorUrl', error_url
        end
        xml.target!
      end


      def do_soap_request action, xml
        req_headers= {
          'Content-Type' => 'text/xml; charset=utf-8',
          'Soapaction' => action,
        }
        ssl_post(SERVICE_URL, build_request(@options, action, xml), req_headers)
      end
      

      def build_request(account, action,  body)
        xml = Builder::XmlMarkup.new :indent => 2

        xml.instruct!
        xml.tag! 'SOAP-ENV:Envelope', ENVELOPE_NAMESPACES do
          xml.tag! 'SOAP-ENV:Body' do
            xml.tag! 'm:createSession', 'xmlns:m' => 'https://ipayment.de/service_v3/extern' do
            #<m:createSession xmlns:m="https://ipayment.de/service_v3/extern">
            #xml.tag! action do
              xml.tag! 'accountData' do
                xml.tag! 'accountId', account[:account_id]
                xml.tag! 'trxuserId', account[:application_id]
                xml.tag! 'trxpassword', account[:application_pw]
                xml.tag! 'adminactionpassword', account[:admin_pw]
              end
                xml << body
            end

          end
        end
        xml.target!
      end
    end
  end
end


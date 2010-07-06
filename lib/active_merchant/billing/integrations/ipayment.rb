require File.dirname(__FILE__) + '/ipayment/helper.rb'
require File.dirname(__FILE__) + '/ipayment/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:

=begin
  ==USAGE:

  in template do:
  <% payment_service_for 1, 'foo', :service => 'ipayment',
                                 :amount => 50,
                                 :currency => 'EUR',
                                 :account_id => '99999',
                                 :application_id => '99999',
                                 :application_pw => '0',
                                 :admin_pw => '5cfgRT34xsdedtFLdfHxj7tfwx24fe',
                                 :redirect_url => url_for(:action => 'success', :only_path => false),
                                 :error_url => url_for(:action => 'error', :only_path => false) do |service| %>
                                 end

    <% service.billing_address :city => 'Landau',
                               :address1 => 'Queichstr. 12',
                               :address2 => '',
                               :state => '',
                               :zip => '76829',
                               :country => 'DE'%>

    Name: <%= text_field_tag 'addr_name' %>
    CC number: <%= text_field_tag 'cc_number' %>
    Exp Date Month: <%= text_field_tag 'cc_expdate' %>
    Exp Date Year: <%= text_field_tag 'cc_expdate_year' %>
    CVC Checkcode: <%= text_field_tag 'cc_checkcode' %>

    <%=  submit_tag 'go' %>
  <% end %>


  in the success action of your controller do:

  notify = Ipayment::Notification.new(request.raw_post)
  if notify.acknowledge '99999' #application_id
    if notify.complete?
      #everything went fine
      transaction_id = notify.transaction_id
    end
  end



=end
      
      module Ipayment 

        #data to test ipayment service
        TEST_ACCOUNT_ID = '99999'
        TEST_APPLICATION_ID = '99999'
        TEST_APPLICATION_PW = '0'
        TEST_ADMIN_PW='5cfgRT34xsdedtFLdfHxj7tfwx24fe'

        def self.testify options
          options[:account_id] = ActiveMerchant::Billing::Base.integration_mode == :test ? TEST_ACCOUNT_ID : options[:account_id]
          options[:application_id] = ActiveMerchant::Billing::Base.integration_mode == :test ? TEST_APPLICATION_ID : options[:application_id]
          options[:application_pw] = ActiveMerchant::Billing::Base.integration_mode == :test ? TEST_APPLICATION_PW : options[:application_pw]
          options[:admin_pw] = ActiveMerchant::Billing::Base.integration_mode == :test ? TEST_ADMIN_PW : options[:admin_pw]
          options
        end

        def self.service_url options

          options = self.testify options

          account_id = options[:account_id]
          url = 'https://ipayment.de/merchant/'
          url += account_id.to_s
          url += '/processor/2.0/'
          url
        end

        def self.notification(post)
          Notification.new(post)
        end

      end
    end
  end
end

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Ipayment
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          
          
          def initialize(order, account, options = {})
            options = ActiveMerchant::Billing::Integrations::Ipayment.testify options
            account_id = options.delete(:account_id)
            application_id = options.delete(:application_id)
            application_pw = options.delete(:application_pw)
            admin_pw = options.delete(:admin_pw)

            redirect_url = options.delete(:redirect_url)
            error_url = options.delete(:error_url)

            #in super there is a assert_valid_keys check TODO remove
            super

            gateway = IpaymentGateway.new(
              :account_id => account_id,
              :application_id => application_id,
              :application_pw => application_pw,
              :admin_pw => admin_pw
            )

            session_id = gateway.generate_session_id(options[:amount],
                                                      options[:currency],
                                                     'preauth',
                                                      redirect_url,
                                                      error_url)
            add_field('ipayment_session_id', session_id)

            add_field('silent', '1') #use silent cgi mode
            if ActiveMerchant::Billing::Base.integration_mode == :test
              #remove double transaction check in test mode
              add_field('check_double_trx', 0) 
            end
            add_field('return_paymentdata_details', 1)
          end

          mapping :currency, 'trx_currency'

          mapping :amount, 'trx_amount'
       
          mapping :billing_address, :city     => 'addr_city',
                                    :address1 => 'addr_street',
                                    :address2 => 'addr_street2',
                                    :state    => 'addr_state',
                                    :zip      => 'addr_zip',
                                    :country  => 'addr_country'

        end
      end
    end
  end
end

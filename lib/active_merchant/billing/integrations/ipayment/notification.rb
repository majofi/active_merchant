require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Ipayment
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          def complete?
            status == "SUCCESS" && params['ret_errorcode'] == '0' #TODO redirect also possible (3DS)
          end

          def error_code
            params['ret_errorcode']
          end

          def error_msg
            params['ret_errormsg']
          end

          def transaction_id
            params['ret_trx_number']
          end

          #anonymous cc number to be stored or displayed
          def cc_number
            params['paydata_cc_number']
          end

          def cc_owner_name
            params['paydata_cc_cardowner']
          end

          def cc_exp_date
            params['paydata_cc_expdate']
          end

          def cc_card_type
            params['paydata_cc_typ']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['trx_amount']
          end

          def currency
            params['trx_currency_type']
          end

          # Status of transaction. List of possible values:
          # <tt>SUCESS</tt>
          # <tt>ERROR</tt>
          # <tt>REDIRECT</tt>
          def status
            params['ret_status']
          end

          # Acknowledge the transaction to Ipayment. This method has to be called after a new 
          # apc arrives. Ipayment will verify that all the information we received are correct and will return a 
          # ok or a fail. 
          # 
          # Example:
          # 
          #   def ipn
          #     notify = IpaymentNotification.new(request.raw_post)
          #
          #     if notify.acknowledge 
          #       ... process order ... if notify.complete?
          #     else
          #       ... log possible hacking attempt ...
          #     end
          def acknowledge application_id

            #check trxuserid which is a secret to the user
            return params['trxuser_id'] == application_id
          end

          private
          def parse(post)
            @params = post
          end

        end
      end
    end
  end
end

require File.dirname(__FILE__) + '/ipayment/helper.rb'
require File.dirname(__FILE__) + '/ipayment/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:

#TODO
      # The notify_url is the URL that the Nochex IPN will be sent.  You can
      # handle the notification in your controller action as follows:
      #
      #   class NotificationController < ApplicationController
      #     include ActiveMerchant::Billing::Integrations
      #
      #     def notify
      #       notification =  Nochex::Notification.new(request.raw_post)
      #
      #       begin
      #         # Acknowledge notification with Nochex
      #         raise StandardError, 'Illegal Notification' unless notification.acknowledge
      #           # Process the payment
      #       rescue => e
      #           logger.warn("Illegal notification received: #{e.message}")
      #       ensure
      #           head(:ok)
      #       end
      #     end
      #   end


      module Ipayment 

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

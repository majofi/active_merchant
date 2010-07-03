require 'test_helper'

class IpaymentModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations


  def test_test_mode
    ActiveMerchant::Billing::Base.integration_mode = :test
    assert_equal 'https://ipayment.de/merchant/99999/processor/2.0/', Ipayment.service_url({})
  end

  def test_production_mode
    ActiveMerchant::Billing::Base.integration_mode = :production
    assert_equal 'https://ipayment.de/merchant/123/processor/2.0/', Ipayment.service_url({:account_id => '123'})
  end

  def test_testify
    options = {:account_id => "789", :application_id => '999', :application_pw => 'rrrr', :admin_pw => 'topsecret', :foo => "bar"}
    new_options = Ipayment.testify options
    assert_equal Ipayment::TEST_ACCOUNT_ID, new_options[:account_id]
    assert_equal Ipayment::TEST_APPLICATION_ID, new_options[:application_id]
    assert_equal Ipayment::TEST_APPLICATION_PW, new_options[:application_pw]
    assert_equal Ipayment::TEST_ADMIN_PW, new_options[:admin_pw]
  end

  def test_testify_production_mode
    ActiveMerchant::Billing::Base.integration_mode = :production
    options = {:account_id => "789", :application_id => '999', :application_pw => 'rrrr', :admin_pw => 'topsecret', :foo => "bar"}
    new_options = Ipayment.testify options
    assert_equal '789', new_options[:account_id]
    assert_equal '999', new_options[:application_id]
    assert_equal 'rrrr', new_options[:application_pw]
    assert_equal 'topsecret', new_options[:admin_pw]
  end

  def test_notification_method
    assert_instance_of Ipayment::Notification, Ipayment.notification('name=cody')
  end
end 

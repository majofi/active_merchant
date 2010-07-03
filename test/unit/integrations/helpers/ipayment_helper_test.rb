require 'test_helper'

class IpaymentHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def setup
    @helper = Ipayment::Helper.new('order-500','cody@example.com',
                                              :amount => 500,
                                              :currency => 'USD',
                                              :account_id => '123',
                                              :application_id => '345',
                                              :application_pw => '678',
                                              :admin_pw => '321')
  end
 
  def test_basic_helper_fields
    assert_field 'trx_currency', 'EUR'
    assert_field 'silent', '1'
    assert_field 'return_paymentdata_details', '1'
  end

  def test_address_mapping
    @helper.billing_address :address1 => '1 My Street',
                            :address2 => 'foo',
                            :city => 'Leeds',
                            :state => 'Yorkshire',
                            :zip => 'LS2 7EE',
                            :country  => 'CA'
   
    assert_field 'addr_street', '1 My Street'
    assert_field 'addr_street2', 'foo'
    assert_field 'addr_city', 'Leeds'
    assert_field 'addr_state', 'Yorkshire'
    assert_field 'addr_zip', 'LS2 7EE'
    assert_field 'addr_country', 'CA'
  end
  
  def test_unknown_address_mapping
    @helper.billing_address :farm => 'BAR'
    assert_not_equal 'BAR', @helper.fields['farm']
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end
  
  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'My Street'
    assert_equal fields, @helper.fields
  end
end

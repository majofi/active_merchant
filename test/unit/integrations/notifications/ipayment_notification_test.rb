require 'test_helper'

class IpaymentNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @ipayment = Ipayment::Notification.new(http_raw_data)
  end

  def test_accessors
    assert @ipayment.complete?
    assert_equal "SUCCESS", @ipayment.status
    assert_equal "1-44647126", @ipayment.transaction_id
    assert_equal "51", @ipayment.gross
    assert_equal "EUR", @ipayment.currency
  end

  def test_compositions
    assert_equal Money.new(5100, 'EUR'), @ipayment.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement    
    assert @ipayment.acknowledge '99999'
  end

  def test_no_acknowledgement
    assert(!@ipayment.acknowledge('123123'))
  end

  def test_cc_number
    assert_equal 'XXXXXXXXXXXX5100', @ipayment.cc_number
  end
  
  def test_cc_owner_name
    assert_equal 'Max Tester', @ipayment.cc_owner_name
  end
  
  def test_cc_exp_date
    assert_equal '0111', @ipayment.cc_exp_date
  end

  def test_complete
    assert(@ipayment.complete?)
  end

  def test_not_complete
    @ipayment = Ipayment::Notification.new(http_error_raw_data)
    assert(!@ipayment.complete?)
    assert_equal('Uhhh someting went wrong', @ipayment.error_msg)
  end



  private
  def http_raw_data
    "addr_name=Max+Tester&commit=go
     &trx_amount=51
     &addr_zip=76829
     &trxuser_id=99999
     &trx_currency=EUR
     &addr_city=Landau
     &addr_street=Qeichstr.+12
     &addr_country=DE
     &trx_currency_type=EUR
     &trx_typ=preauth
     &trx_paymenttyp=cc
     &ret_transdate=03.07.10
     &ret_transtime=12:14:47
     &ret_errorcode=0
     &ret_authcode=
     &ret_ip=92.226.228.24
     &ret_booknr=1-44647126
     &ret_trx_number=1-44647126
     &redirect_needed=0
     &trx_paymentmethod=MasterCard
     &trx_paymentdata_country=US
     &trx_remoteip_country=DE
     &paydata_cc_cardowner=Max+Tester
     &paydata_cc_number=XXXXXXXXXXXX5100
     &paydata_cc_expdate=0111
     &paydata_cc_typ=MasterCard
     &ret_status=SUCCESS"
  end

    def http_error_raw_data
    "addr_name=Max+Tester&commit=go
     &trx_amount=51
     &addr_zip=76829
     &trxuser_id=99999
     &trx_currency=EUR
     &addr_city=Landau
     &addr_street=Qeichstr.+12
     &addr_country=DE
     &trx_currency_type=EUR
     &trx_typ=preauth
     &trx_paymenttyp=cc
     &ret_transdate=03.07.10
     &ret_transtime=12:14:47
     &ret_errorcode=1
     &ret_errormsg=Uhhh someting went wrong
     &ret_authcode=
     &ret_ip=92.226.228.24
     &ret_booknr=1-44647126
     &ret_trx_number=1-44647126
     &redirect_needed=0
     &trx_paymentmethod=MasterCard
     &trx_paymentdata_country=US
     &trx_remoteip_country=DE
     &paydata_cc_cardowner=Max+Tester
     &paydata_cc_number=XXXXXXXXXXXX5100
     &paydata_cc_expdate=0111
     &paydata_cc_typ=MasterCard
     &ret_status=ERROR"
  end

end

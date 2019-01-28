require 'spec_helper'

RSpec.describe Bitmex::User do
  let(:client) { Bitmex::Client.new testnet: true, api_key: ENV['API_KEY'], api_secret: ENV['API_SECRET'] }

  describe 'attributes' do
    it '#firstname' do
      firstname = client.user.firstname
      expect(firstname).to eq 'Iulian'
    end
    it '#preferences.showLocaleNumbers' do
      showLocaleNumbers = client.user.preferences.showLocaleNumbers
      expect(showLocaleNumbers).to be_truthy
    end
    it '#wrong' do
      wrong = client.user.wrong
      expect(wrong).to be_nil
    end
  end

  xit '#update_attributes'

  it '#affiliate_status' do
    status = client.user.affiliate_status
    expect(status.affiliatePayout).to be_nil
  end

  xit '#cancel_withdrawal'

  it '#check_referral_code' do
    discount = client.user.check_referral_code '7wUFhY'
    expect(discount).to eq 0.1
    discount = client.user.check_referral_code 'WRONG'
    expect(discount).to be_nil
  end

  it '#commission' do
    commission = client.user.commission
    expect(commission.XBTUSD.settlementFee).to eq 0
  end

  xit '#communication_token'
  xit '#confirm_email'
  xit '#confirm_enable_tfa'
  xit '#confirm_withdrawal'

  it '#deposit_address' do
    address = client.user.deposit_address 'XBt'
    expect(address).to eq '"2NBMEXtoNm2fJgQEQ85xLTdzHfNMdKYTses"'
  end

  xit '#disable_tfa'

  it '#execution_history' do
    history = client.user.execution_history 'XBTUSD', Date.new(2019, 1, 17)
    expect(history.first.side).to eq 'Buy'
    expect(history.first.orderQty).to eq 100
  end

  xit '#logout'
  xit '#logout_all'

  it '#margin' do
    margin = client.user.margin 'XBt'
    expect(margin.availableMargin).to be >= 500_000
  end

  it '#min_withdrawal_fee' do
    fee = client.user.min_withdrawal_fee 'XBt'
    expect(fee.minFee).to eq 20000
  end

  xit '#preferences'
  xit '#request_enable_tfa'
  xit '#request_withdrawal'

  it '#wallet' do
    wallet = client.user.wallet
    expect(wallet.amount).to eq 982444
  end

  it '#wallet_history' do
    wallet_history = client.user.wallet_history
    expect(wallet_history.last.transactType).to eq 'Transfer'
    expect(wallet_history.last.amount).to eq 1000000
  end

  it '#wallet_summary' do
    wallet_summary = client.user.wallet_summary
    expect(wallet_summary.first.transactType).to eq 'RealisedPNL'
    expect(wallet_summary.first.amount).to eq -17556
  end

  it '#events' do
    events = client.user.events
    expect(events.size).to be >= 1
    expect(events.first.userId).to eq 173686
  end
end

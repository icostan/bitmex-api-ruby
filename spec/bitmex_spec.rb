require 'spec_helper'

RSpec.describe Bitmex do
  let(:secret) { 'chNOOS4KvNXR_Xq4k4c9qsfoKWvnDecLATCRlcBwyKDYnWgO' }

  describe '.signature' do
    it 'GET w/o data' do
      s = subject.signature secret, 'GET', '/api/v1/instrument', 1518064236, nil, nil
      expect(s).to eq 'c7682d435d0cfe87c16098df34ef2eb5a549d4c5a3c2b1f0f77b8af73423bf00'
    end

    it 'POST w/ data' do
      data = '{"symbol":"XBTM15","price":219.0,"clOrdID":"mm_bitmex_1a/oemUeQ4CAJZgP3fjHsA","orderQty":98}'
      s = subject.signature secret, 'POST', '/api/v1/order', 1518064238, data, nil
      expect(s).to eq '1749cd2ccae4aa49048ae09f0b95110cee706e0944e6a14ad0b3a8cb45bd336b'
    end
  end
end

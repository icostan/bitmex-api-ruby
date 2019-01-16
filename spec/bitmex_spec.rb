require 'spec_helper'

RSpec.describe Bitmex do
  it '.signature' do
    s = subject.signature 'chNOOS4KvNXR_Xq4k4c9qsfoKWvnDecLATCRlcBwyKDYnWgO', 'GET', '/api/v1/instrument', 1518064236, ''
    expect(s).to eq 'c7682d435d0cfe87c16098df34ef2eb5a549d4c5a3c2b1f0f77b8af73423bf00'
  end
end

# encoding: utf-8

require 'spec_helper'

describe SQL::Generator::Relation::Insertion, '#to_subquery' do
  subject { object.to_subquery }

  let(:object) { described_class.new }

  it 'delegates to #to_s' do
    sql = double('sql')
    expect(object).to receive(:to_s).with(no_args).and_return(sql)
    should equal(sql)
  end
end

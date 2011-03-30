# encoding: utf-8

shared_examples_for 'a generated SQL expression' do
  it { should respond_to(:to_s) }

  its(:to_s) { should be_kind_of(String) }
end

shared_examples_for 'a generated SQL SELECT query' do
  it_should_behave_like 'a generated SQL expression'

  its(:name) { should == relation_name }

  its(:name) { should be_frozen }
end

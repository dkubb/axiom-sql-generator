# encoding: utf-8

shared_examples_for 'a generated SQL expression' do
  it { should respond_to(:to_s) }

  its(:to_s) { should be_kind_of(String) }

  if String.public_method_defined?(:encoding)
    it 'is UTF-8 encoded' do
      subject.to_s.encoding.should equal(Encoding::UTF_8)
    end
  end
end

shared_examples_for 'a generated SQL SELECT query' do
  it_should_behave_like 'a generated SQL expression'

  its(:name) { should == relation_name }

  its(:name) { should be_frozen }
end

shared_examples_for 'a generated SQL expression' do
  it { should respond_to(:to_s) }
end

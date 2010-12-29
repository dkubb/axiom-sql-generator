shared_examples_for 'a generated SQL query' do
  it_should_behave_like 'an idempotent method'

  it { should be_frozen }

  it { should_not equal(@original) }
end

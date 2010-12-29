require 'spec_helper'

describe Generator, '.handler_for' do
  subject { object.handler_for(visitable) }

  let(:object) { Generator }

  after do
    # remove the handler cache after each spec
    Generator.module_eval { remove_instance_variable(:@handlers) }
  end

  context 'with a handled object' do
    let(:header)    { [ [ :id, Integer ] ]                    }
    let(:body)      { [ [ 1 ] ].each                          }
    let(:visitable) { BaseRelation.new('users', header, body) }

    it_should_behave_like 'an idempotent method'

    it { should == :visit_veritas_base_relation }
  end

  context 'with an unhandled object' do
    let(:visitable) { mock('Not Handled') }

    specify { expect { subject }.to raise_error(Generator::UnknownObject, "No handler for #{visitable.class}") }
  end
end

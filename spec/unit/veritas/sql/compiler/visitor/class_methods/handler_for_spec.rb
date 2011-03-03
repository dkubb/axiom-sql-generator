require 'spec_helper'

describe Visitor, '.handler_for' do
  subject { object.handler_for(visitable) }

  let(:object) { Class.new(Visitor) }

  before :all do
    module ::MySpec
      class Visitable; end
    end
  end

  after :all do
    MySpec.class_eval { remove_const(:Visitable) }
    Object.class_eval { remove_const(:MySpec)    }
  end

  context 'with an object handled by a public method' do
    let(:visitable) { MySpec::Visitable.new }

    before do
      object.class_eval do
        remove_instance_variable(:@handlers) if instance_variable_defined?(:@handlers)
        define_method(:visit_my_spec_visitable) {}
      end
    end

    after do
      object.class_eval do
        remove_instance_variable(:@handlers)
        remove_method(:visit_my_spec_visitable)
      end
    end

    it_should_behave_like 'an idempotent method'

    it { should == :visit_my_spec_visitable }
  end

  context 'with an object handled by a private method' do
    let(:visitable) { MySpec::Visitable.new }

    before do
      object.class_eval do
        remove_instance_variable(:@handlers) if instance_variable_defined?(:@handlers)
        define_method(:visit_my_spec_visitable) {}
        private :visit_my_spec_visitable
      end
    end

    after do
      object.class_eval do
        remove_instance_variable(:@handlers)
        remove_method(:visit_my_spec_visitable)
      end
    end

    it_should_behave_like 'an idempotent method'

    it { should == :visit_my_spec_visitable }
  end

  context 'with an unhandled object' do
    let(:visitable) { mock('unhandled object') }

    specify { expect { subject }.to raise_error(object::UnknownObject, "No handler for #{visitable.class} in #{object}") }
  end
end

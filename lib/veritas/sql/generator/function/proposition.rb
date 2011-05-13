# encoding: utf-8

module Veritas
  module SQL
    module Generator
      module Function

        # Generates an SQL statement for a proposition function
        module Proposition
          include Function

          # Visit a Tautology
          #
          # @param [Function::Proposition::Tautology] _tautology
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_proposition_tautology(_tautology)
            MATCH_ALL
          end

          # Visit a Contradiction
          #
          # @param [Function::Proposition::Contradiction] _contradiction
          #
          # @return [#to_s]
          #
          # @api private
          def visit_veritas_function_proposition_contradiction(_contradiction)
            MATCH_NONE
          end

        end # module Proposition
      end # module Function
    end # module Generator
  end # module SQL
end # module Veritas

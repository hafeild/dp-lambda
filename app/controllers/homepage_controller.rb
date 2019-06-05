class HomepageController < ApplicationController
    def show
        @analyses = Analysis.last(9).reverse
        @assignment_groups = AssignmentGroup.last(9).reverse
        @datasets = Dataset.last(9).reverse
        @examples = Example.last(9).reverse
        @software = Software.last(9).reverse
    end
end

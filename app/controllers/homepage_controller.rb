class HomepageController < ApplicationController
    def show
        @analyses = Analysis.where({creator: current_user}).or(Analysis.where({is_draft: false})).last(9).reverse
        @assignment_groups = AssignmentGroup.where({creator: current_user}).or(AssignmentGroup.where({is_draft: false})).last(9).reverse
        @datasets = Dataset.where({creator: current_user}).or(Dataset.where({is_draft: false})).last(9).reverse
        @examples = Example.where({creator: current_user}).or(Example.where({is_draft: false})).last(9).reverse
        @software = Software.where({creator: current_user}).or(Software.where({is_draft: false})).last(9).reverse
    end
end

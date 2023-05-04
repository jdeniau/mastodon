# frozen_string_literal: true

class Api::V1::Peers::SearchController < Api::BaseController
  before_action -> { authorize_if_got_token! :read, :'read:search' }
  before_action :set_domains

  def index
    render json: @domains
  end

  private

  def set_domains
    return if !Chewy.enabled? || params[:q].blank?

    @domains = InstancesIndex.query(function_score: {
      query: {
        prefix: {
          domain: params[:q],
        },
      },

      field_value_factor: {
        field: 'accounts_count',
        modifier: 'log2p',
      },
    }).limit(10).pluck(:domain)
  end
end

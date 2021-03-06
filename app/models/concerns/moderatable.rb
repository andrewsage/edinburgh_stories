module Moderatable
  extend ActiveSupport::Concern

  module ClassMethods
    def moderation_record_query
      ModerationRecordQuery.new(self, moderation_record)
    end

    def by_state(state)
      joins(moderation_record_query.first_join)
        .joins(moderation_record_query.second_join)
        .where(moderation_record_query.where(state))
    end

    def not_in_state(state)
      joins(moderation_record_query.first_join)
        .joins(moderation_record_query.second_join)
        .where(moderation_record_query.where_not(state))
    end

    def moderated
      not_in_state('unmoderated')
    end

    def unmoderated
      by_state('unmoderated')
    end

    def approved
      by_state('approved')
    end

    def rejected
      by_state('rejected')
    end

    def moderation_record
      #TODO raise error if not implemented
    end
  end

  def moderation_records
    #TODO raise error if not implemented
  end

  def approve!
    update_state!('approved')
  end

  def reject!(comment)
    update_state!('rejected', comment)
  end

  def unmoderate!
    update_state!('unmoderated')
  end

  def previous_state
    state = current_record.try(:from_state)
    state || ModerationStateMachine::DEFAULT_STATE
  end

  def current_state
    state = current_record.try(:to_state)
    state || ModerationStateMachine::DEFAULT_STATE
  end

  def current_state_reason
    current_record.try(:comment)
  end

  def last_moderated_at
    current_record.try(:updated_at)
  end

  def approved?
    current_state == 'approved'
  end

  def unmoderated?
    current_state == 'unmoderated'
  end

  private

  def current_record
    moderation_records
      .order('created_at DESC')
      .limit(1)
      .first
  end

  def update_state!(state, comment=nil)
    moderation_records.create!(from_state: current_state, to_state: state, comment: comment)
  end
end

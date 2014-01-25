class Detour::MembershipsController < Detour::ApplicationController
  def create
    group = Detour::Group.find(params[:membership][:group_id])

    @membership = Detour::Membership.new(group_id: group.id, member_type: params[:membership][:member_type])
    @member = flaggable_class.flaggable_find! params[:membership][:member_id]

    if @membership.update_attributes(member_id: @member.id)
      flash[:notice] = "A new member has been added to the group."
      render "detour/shared/success"
    else
      render_errors
    end
  rescue ActiveRecord::RecordNotFound => e
    @membership ||= Detour::Membership.new
    @membership.errors.add(:base, e.message)
    render_errors
  end

  private

  def flaggable_class
    params[:membership][:member_type].constantize
  end

  def render_errors
    @model = @membership
    render "detour/shared/error"
  end
end

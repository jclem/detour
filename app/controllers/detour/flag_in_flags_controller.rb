class Detour::FlagInFlagsController < Detour::ApplicationController
  before_filter :ensure_flaggable_type_exists

  def index
    feature = Detour::Feature.find_by_name!(feature_name)
    @flags  = feature.flag_in_flags.where(flaggable_type: flaggable_class.to_s)
  end

  def create
    @feature = Detour::Feature.find_by_name! feature_name
    ids      = params[:ids].split(",")
    @errors   = []

    Detour::Feature.transaction do
      begin
        ids.each do |id|
          flaggable = flaggable_class.flaggable_find! id
          flag      = @feature.send("#{flaggable_type}_flag_ins").new flaggable: flaggable

          unless flag.save
            @errors.concat flag.errors.full_messages
          end
        end
      rescue ActiveRecord::RecordNotFound => e
        @errors << e.message
      end

      if @errors.any?
        raise ActiveRecord::Rollback
      end
    end

    if @errors.empty?
      flash[:notice] = success_message
      render :success
    else
      render :error
    end
  end

  def destroy
    feature = Detour::Feature.find_by_name!(feature_name)
    @flag   = feature.flag_in_flags.find(params[:id])
    @flag.destroy
    flash[:notice] = "#{feature_name} flag-in for #{flaggable_class} #{@flag.flaggable.send flaggable_class.detour_flaggable_find_by} has been deleted."
    redirect_to flag_in_flags_path feature.name, flaggable_type
  end

  private

  def feature_name
    params[:feature_name]
  end
  helper_method :feature_name

  def flaggable_type
    params[:flaggable_type]
  end
  helper_method :flaggable_type

  def flaggable_class
    flaggable_type.classify.constantize
  end
  helper_method :flaggable_class

  def success_message
    plural = params[:ids].split(",").length > 1
    klass  = plural ? flaggable_class.to_s.pluralize : flaggable_class
    has    = plural ? "have" : "has"

    flash[:notice] = "#{klass} #{params[:ids].split(",").join(", ")} #{has} been flagged in to #{@feature.name}"
  end
end

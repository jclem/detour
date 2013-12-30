class Detour::FlaggableFlagsController < Detour::ApplicationController
  before_filter :ensure_flaggable_type_exists

  def index
    feature = Detour::Feature.find_by_name!(feature_name)
    @flags  = feature.send("#{flag_type}_flags").where(flaggable_type: flaggable_class.to_s)
  end

  def create
    @feature = Detour::Feature.find_by_name! feature_name
    ids      = params[:ids].split(",")
    @errors   = []

    Detour::Feature.transaction do
      begin
        ids.each do |id|
          flaggable = flaggable_class.flaggable_find! id
          flag      = @feature.send("#{flaggable_type}_#{flag_type.pluralize}").new flaggable: flaggable

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
    @flag   = feature.send("#{flag_type}_flags").find(params[:id])
    @flag.destroy
    flash[:notice] = "#{feature_name} #{flag_noun} for #{flaggable_class} #{@flag.flaggable.send flaggable_class.detour_flaggable_find_by} has been deleted."
    redirect_to send("#{flag_type}_flags_path", feature.name, flaggable_type)
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

  def flag_type
    request.path.split("/")[2].underscore.singularize
  end
  helper_method :flag_type

  def flag_verb
    flag_type == "flag_in" ? "flagged in to" : "opted out of"
  end
  helper_method :flag_verb

  def flag_noun
    flag_type.dasherize
  end
  helper_method :flag_noun

  def success_message
    plural = params[:ids].split(",").length > 1
    klass  = plural ? flaggable_class.to_s.pluralize : flaggable_class
    has    = plural ? "have" : "has"

    flash[:notice] = "#{klass} #{params[:ids].split(",").join(", ")} #{has} been #{flag_verb} #{@feature.name}"
  end
end

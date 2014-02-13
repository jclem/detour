module Detour::FlaggableFlagsHelper
  def feature_name
    params[:feature_name]
  end

  def flag_noun
    flag_type.dasherize
  end

  def flag_title
    flag_noun.capitalize
  end

  def flag_type
    params[:flag_type].underscore.singularize
  end

  def flag_verb
    flag_type == "flag_in" ? "flagged in to" : "opted out of"
  end

  def flaggable_type
    params[:flaggable_type]
  end
end

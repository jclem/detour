module Detour::FlagsHelper
  def spacer_count
    names_count = @flag_form.group_names.length
    difference  = 10 - names_count
    count       = difference < 0 ? 0 : difference
  end
end

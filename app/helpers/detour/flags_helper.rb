module Detour::FlagsHelper
  def github_prefix
    "https://github.com/#{ENV["DETOUR_GITHUB_REPO"]}/blob/#{ENV["DETOUR_GITHUB_BRANCH"]}/"
  end

  def spacer_count
    names_count = @flag_form.groups.length
    difference  = 10 - names_count
    count       = difference < 0 ? 0 : difference
  end
end

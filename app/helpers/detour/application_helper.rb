module Detour::ApplicationHelper
  def table(&block)
    content_tag :div, class: "table-responsive" do
      content_tag :table, class: "table table-striped" do
        yield
      end
    end
  end
end

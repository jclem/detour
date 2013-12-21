module Detour::ApplicationHelper
  def table(&block)
    content_tag :div, class: "table-responsive" do
      content_tag :table, class: "table table-striped" do
        yield
      end
    end
  end

  def modal(options, &block)
    content_tag :div, id: options[:id], class: "modal #{options[:fade].present?}", tabindex: "-1", role: "dialog", aria_labbeledby: "#{options[:id]}-modal-label", aria_hidden: "true" do
      content_tag :div, class: "modal-dialog" do
        content_tag :div, class: "modal-content" do
          content_tag(:div, class: "modal-header") do
            content_tag :button, "&times;", class: "close", data_dismiss: "modal", aria_hidden: "true"
            content_tag :h4, options[:title], id: "#{options[:id]}-modal-label"
          end +

          content_tag(:div, class: "modal-body") do
            yield
          end
        end
      end
    end
  end

  def modal_footer(&block)
    content_tag :div, class: "modal-footer" do
      yield
    end
  end
end

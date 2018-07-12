module CrawlerJobDecorator
  def status_label
    type =
        case
        when waiting?; 'secondary'
        when running?; 'primary'
        when failed?; 'danger'
        when completed?; 'success'
        end
    content_tag :span, status.capitalize, class: "badge badge-#{type}"
  end
end

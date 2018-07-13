module CrawlerJobDecorator
  def status_label(options)
    type =
        case
        when waiting?; 'secondary'
        when running?; 'primary'
        when canceled?; 'warning'
        when failed?; 'danger'
        when completed?; 'success'
        end
    content_tag :span, status.capitalize, options.reverse_merge(class: "badge badge-#{type}")
  end
end

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

  def remaining_time
    return '' unless running?
    content_tag :i, "#{1 + (total_count - current_count) * CrawlerJob::WAIT_TIME / 60} minutes later"
  end
end
